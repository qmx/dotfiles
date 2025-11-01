#!/usr/bin/env python3
"""
GGUF Model Downloader
Download GGUF quantizations from HuggingFace Hub
"""

import os
import re
import sys
from pathlib import Path
from typing import List, Optional, Tuple

import click
from huggingface_hub import list_repo_files, snapshot_download
from huggingface_hub.utils import RepositoryNotFoundError, HfHubHTTPError
from rich.console import Console
from rich.table import Table
from rich.progress import Progress, SpinnerColumn, TextColumn

console = Console()


def parse_gguf_info(filename: str) -> Tuple[Optional[str], Optional[float]]:
    """
    Parse quantization type and size from GGUF filename.
    
    Args:
        filename: The GGUF filename
        
    Returns:
        Tuple of (quantization_type, size_in_gb)
    """
    if not filename.endswith('.gguf'):
        return None, None
    
    # Common quantization patterns
    quant_patterns = [
        r'[-_](Q\d+_[A-Z0-9_]+)',  # Q4_K_M, Q8_0, etc.
        r'[-_](IQ\d+_[A-Z0-9_]+)',  # IQ1_S, IQ2_XXS, etc.
        r'[-_](F\d+)',  # F16, F32
        r'[-_](BF\d+)',  # BF16
    ]
    
    quant_type = None
    for pattern in quant_patterns:
        match = re.search(pattern, filename, re.IGNORECASE)
        if match:
            quant_type = match.group(1).upper()
            break
    
    # If no pattern matched, try to extract from the end of filename before .gguf
    if not quant_type:
        # Remove .gguf and split by - or _
        base = filename[:-5]
        parts = re.split(r'[-_]', base)
        if parts:
            # Take the last part as potential quant type
            potential_quant = parts[-1].upper()
            # Check if it looks like a quantization
            if re.match(r'^[QFI]\d+', potential_quant) or potential_quant in ['F16', 'F32', 'BF16']:
                quant_type = potential_quant
    
    return quant_type, None


def get_file_size(repo_files_info: List) -> dict:
    """
    Extract file sizes from repo files info.
    
    Args:
        repo_files_info: List of file info from HuggingFace API
        
    Returns:
        Dictionary mapping filenames to sizes in GB
    """
    file_sizes = {}
    for file_info in repo_files_info:
        if hasattr(file_info, 'size') and file_info.size:
            size_gb = file_info.size / (1024 ** 3)
            file_sizes[file_info.rfilename] = size_gb
    return file_sizes


def list_gguf_files(repo_id: str, token: Optional[str] = None) -> List[Tuple[str, str, float]]:
    """
    List all GGUF files in a repository.
    
    Args:
        repo_id: HuggingFace repository ID
        token: Optional HuggingFace token
        
    Returns:
        List of tuples (filename, quantization_type, size_in_gb)
    """
    try:
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console,
            transient=True,
        ) as progress:
            progress.add_task(description=f"Fetching files from {repo_id}...", total=None)
            
            # Get all files in the repository
            files = list_repo_files(repo_id, token=token)
            
            # Get detailed file info (includes sizes)
            from huggingface_hub import HfApi
            api = HfApi()
            repo_info = api.repo_info(repo_id, token=token, files_metadata=True)
            
            # Build size mapping
            file_sizes = {}
            if hasattr(repo_info, 'siblings'):
                for sibling in repo_info.siblings:
                    if hasattr(sibling, 'size'):
                        file_sizes[sibling.rfilename] = sibling.size / (1024 ** 3)
    
    except RepositoryNotFoundError:
        console.print(f"[red]Error: Repository '{repo_id}' not found.[/red]")
        console.print("Please check the repository name and your access permissions.")
        sys.exit(1)
    except HfHubHTTPError as e:
        if "401" in str(e):
            console.print("[red]Error: Authentication failed.[/red]")
            console.print("You may need to provide a valid token with --token for private repositories.")
        else:
            console.print(f"[red]Error accessing repository: {e}[/red]")
        sys.exit(1)
    except Exception as e:
        console.print(f"[red]Unexpected error: {e}[/red]")
        sys.exit(1)
    
    # Filter GGUF files and parse their info
    gguf_files = []
    for filename in files:
        if filename.endswith('.gguf'):
            quant_type, _ = parse_gguf_info(filename)
            size_gb = file_sizes.get(filename, 0)
            gguf_files.append((filename, quant_type or "Unknown", size_gb))
    
    return sorted(gguf_files, key=lambda x: (x[1], x[2]))


def display_gguf_table(gguf_files: List[Tuple[str, str, float]], repo_id: str):
    """
    Display GGUF files in a formatted table.
    
    Args:
        gguf_files: List of GGUF file information
        repo_id: Repository ID for the title
    """
    if not gguf_files:
        console.print(f"[yellow]No GGUF files found in {repo_id}[/yellow]")
        return
    
    table = Table(title=f"GGUF Quantizations for {repo_id}")
    table.add_column("Quantization", style="cyan", no_wrap=True)
    table.add_column("Filename", style="green")
    table.add_column("Size", justify="right", style="magenta")
    
    # Group by quantization type
    quant_groups = {}
    for filename, quant_type, size_gb in gguf_files:
        if quant_type not in quant_groups:
            quant_groups[quant_type] = []
        quant_groups[quant_type].append((filename, size_gb))
    
    # Display grouped results
    for quant_type in sorted(quant_groups.keys()):
        for filename, size_gb in quant_groups[quant_type]:
            size_str = f"{size_gb:.2f} GB" if size_gb > 0 else "Unknown"
            table.add_row(quant_type, filename, size_str)
    
    console.print(table)
    
    # Print summary
    total_files = len(gguf_files)
    unique_quants = len(quant_groups)
    console.print(f"\n[bold]Found {total_files} GGUF files with {unique_quants} unique quantizations[/bold]")


def get_mmproj_for_quant(gguf_files: List[Tuple[str, str, float]], quant: str) -> Optional[str]:
    """
    Determine the best mmproj file for a given quantization.

    Args:
        gguf_files: List of all GGUF files
        quant: The quantization type being downloaded

    Returns:
        The mmproj filename to download, or None if not found
    """
    # Find all mmproj files
    mmproj_files = [(f, q) for f, q, _ in gguf_files if 'mmproj' in f.lower()]

    if not mmproj_files:
        return None

    # Heuristic for selecting mmproj based on quantization
    quant_upper = quant.upper()

    # For higher quality quants (Q6, Q8, F16, BF16), prefer F16 mmproj
    # For lower quality quants (Q2, Q3, Q4), prefer F16 but F32 is okay too
    # For IQ quants, prefer F16

    # Priority order based on quantization
    if any(x in quant_upper for x in ['Q8', 'Q6', 'Q5']):
        # High quality quant - prefer F16 > F32 > BF16
        priority = ['F16', 'F32', 'BF16']
    elif any(x in quant_upper for x in ['Q4', 'Q3']):
        # Medium quality quant - prefer F16 > F32 > BF16
        priority = ['F16', 'F32', 'BF16']
    elif any(x in quant_upper for x in ['Q2', 'IQ']):
        # Low quality quant - F16 is still best for compatibility
        priority = ['F16', 'F32', 'BF16']
    elif 'F16' in quant_upper or 'F32' in quant_upper:
        # Full precision - match the precision
        if 'F32' in quant_upper:
            priority = ['F32', 'F16', 'BF16']
        else:
            priority = ['F16', 'F32', 'BF16']
    elif 'BF16' in quant_upper:
        # BF16 model - prefer BF16 mmproj
        priority = ['BF16', 'F16', 'F32']
    else:
        # Default fallback
        priority = ['F16', 'F32', 'BF16']

    # Find the best match based on priority
    for pref in priority:
        for filename, file_quant in mmproj_files:
            # Need exact match to avoid BF16 matching when looking for F16
            file_quant_upper = file_quant.upper()
            if pref == 'F16' and 'BF16' not in file_quant_upper and 'F16' in file_quant_upper:
                return filename
            elif pref == 'BF16' and 'BF16' in file_quant_upper:
                return filename
            elif pref == 'F32' and 'F32' in file_quant_upper:
                return filename

    # If no match found by priority, return the first mmproj file
    return mmproj_files[0][0] if mmproj_files else None


def download_gguf(repo_id: str, quant: str, token: Optional[str] = None, local_dir: Optional[str] = None, include_mmproj: bool = True):
    """
    Download specific GGUF quantization.

    Args:
        repo_id: HuggingFace repository ID
        quant: Quantization type to download
        token: Optional HuggingFace token
        local_dir: Optional local directory (defaults to repo name)
        include_mmproj: Whether to download mmproj files for multimodal support
    """
    # List all GGUF files
    gguf_files = list_gguf_files(repo_id, token)

    if not gguf_files:
        console.print(f"[red]No GGUF files found in {repo_id}[/red]")
        sys.exit(1)

    # Find matching files for the requested quantization
    matching_files = []
    for filename, quant_type, size_gb in gguf_files:
        if quant_type.upper() == quant.upper():
            matching_files.append(filename)
    
    if not matching_files:
        console.print(f"[red]No files found with quantization '{quant}'[/red]")
        console.print("\nAvailable quantizations:")
        unique_quants = sorted(set(q for _, q, _ in gguf_files))
        for q in unique_quants:
            console.print(f"  - {q}")
        sys.exit(1)

    # Check for mmproj file if requested
    mmproj_file = None
    if include_mmproj:
        mmproj_file = get_mmproj_for_quant(gguf_files, quant)
        if mmproj_file and mmproj_file not in matching_files:
            matching_files.append(mmproj_file)

    # Determine local directory
    if not local_dir:
        # Extract repo name and create directory
        repo_name = repo_id.split('/')[-1]
        local_dir = f"./{repo_name}"

    # Create directory if it doesn't exist
    Path(local_dir).mkdir(parents=True, exist_ok=True)

    # Check which files already exist
    existing_files = []
    missing_files = []
    for file in matching_files:
        file_path = Path(local_dir) / file
        if file_path.exists():
            existing_files.append(file)
        else:
            missing_files.append(file)

    console.print(f"\n[bold]Files for quantization '{quant}':[/bold]")
    for file in matching_files:
        if mmproj_file and file == mmproj_file:
            status = "[green]✓[/green]" if file in existing_files else "[yellow]⬇[/yellow]"
            console.print(f"  {status} {file} [cyan](multimodal support)[/cyan]")
        else:
            status = "[green]✓[/green]" if file in existing_files else "[yellow]⬇[/yellow]"
            console.print(f"  {status} {file}")

    if existing_files and not missing_files:
        console.print(f"\n[green]All files already exist in {local_dir}[/green]")
        console.print("[dim]Run with --force to re-download[/dim]")
        return
    elif existing_files:
        console.print(f"\n[yellow]Found {len(existing_files)} existing file(s), downloading {len(missing_files)} missing file(s)[/yellow]")
    else:
        console.print(f"\n[bold]Downloading {len(matching_files)} file(s)[/bold]")

    try:
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console,
        ) as progress:
            progress.add_task(description=f"Downloading to {local_dir}...", total=None)

            # Download only the matching files
            snapshot_download(
                repo_id=repo_id,
                local_dir=local_dir,
                allow_patterns=matching_files,
                token=token
            )

        console.print(f"\n[green]✓ Successfully downloaded to {local_dir}[/green]")
        
    except Exception as e:
        console.print(f"[red]Error during download: {e}[/red]")
        sys.exit(1)


@click.command()
@click.option('--model', '-m', required=True, help='HuggingFace model repository (e.g., unsloth/Llama-3.1-8B-Instruct-GGUF)')
@click.option('--quant', '-q', help='Quantization to download (e.g., Q4_K_M). If not specified, lists all available.')
@click.option('--token', '-t', help='HuggingFace token for private repositories')
@click.option('--local-dir', '-d', help='Local directory to save files (defaults to repository name)')
@click.option('--no-mmproj', is_flag=True, help='Skip downloading mmproj files for multimodal support')
def main(model: str, quant: Optional[str], token: Optional[str], local_dir: Optional[str], no_mmproj: bool):
    """
    GGUF Model Downloader - List and download GGUF quantizations from HuggingFace.

    Examples:

        # List all quantizations
        uv run gguf_downloader.py --model unsloth/Llama-3.1-8B-Instruct-GGUF

        # Download specific quantization (includes mmproj if available)
        uv run gguf_downloader.py --model unsloth/Llama-3.1-8B-Instruct-GGUF --quant Q4_K_M

        # Without mmproj files
        uv run gguf_downloader.py --model unsloth/Llama-3.1-8B-Instruct-GGUF --quant Q4_K_M --no-mmproj

        # With token for private repos
        uv run gguf_downloader.py --model private/model-GGUF --quant Q4_K_M --token hf_xxxxx
    """
    console.print(f"[bold cyan]GGUF Model Downloader[/bold cyan]\n")

    if quant:
        # Download specific quantization
        download_gguf(model, quant, token, local_dir, include_mmproj=not no_mmproj)
    else:
        # List all available quantizations
        gguf_files = list_gguf_files(model, token)
        display_gguf_table(gguf_files, model)
        
        if gguf_files:
            console.print("\n[dim]To download a specific quantization, use:[/dim]")
            console.print(f"[dim]  uv run gguf_downloader.py --model {model} --quant <QUANTIZATION>[/dim]")


if __name__ == "__main__":
    main()