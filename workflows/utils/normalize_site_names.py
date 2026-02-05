#!/usr/bin/env python3
"""
Normalize site names to standard format:
- All lowercase
- Spaces → underscores
- Special characters normalized (ä→a, é→e, etc.)
- Remove problematic characters (commas, parentheses, etc.)

Use this when importing data to ensure consistent naming across:
- Shapefiles
- Chemistry data
- Discharge data
- Reference table
"""

import unicodedata
import re


def normalize_site_name(name: str) -> str:
    """
    Convert a site name to standardized format.

    Examples:
        "Ahtavanjoen vesistoalue" → "ahtavanjoen_vesistoalue"
        "UK_27006" → "uk_27006"
        "Krycklan1" → "krycklan1"
        "Vilajoen vesistöalue" → "vilajoen_vesistoalue"
        "V301502401 (Ratier)" → "v301502401_ratier"
    """
    if not name or not isinstance(name, str):
        return name

    # Normalize unicode (ä → a, é → e, ö → o, etc.)
    normalized = unicodedata.normalize('NFKD', name)
    normalized = normalized.encode('ascii', 'ignore').decode('ascii')

    # Lowercase
    normalized = normalized.lower()

    # Replace spaces and problematic chars with underscores
    normalized = re.sub(r'[\s\-\.]+', '_', normalized)

    # Remove parentheses but keep content
    normalized = re.sub(r'[()]', '_', normalized)

    # Remove other special characters
    normalized = re.sub(r'[,;:\'\"!@#$%^&*+=<>?/\\|`~\[\]{}]', '', normalized)

    # Collapse multiple underscores
    normalized = re.sub(r'_+', '_', normalized)

    # Strip leading/trailing underscores
    normalized = normalized.strip('_')

    return normalized


def create_name_mapping(original_names: list) -> dict:
    """
    Create a mapping from original names to normalized names.

    Returns dict: {original_name: normalized_name}
    """
    return {name: normalize_site_name(name) for name in original_names}


# For R users: can call this from R using reticulate
# reticulate::source_python("normalize_site_names.py")
# normalized <- normalize_site_name("Ahtavanjoen vesistoalue")


if __name__ == "__main__":
    # Test cases
    test_names = [
        "Ahtavanjoen vesistoalue",
        "UK_27006",
        "Vilajoen vesistöalue",
        "V301502401 (Ratier à Saint-Genis-les-Ollières)",
        "cdstation_national_3080660",
        "Krycklan1",
        "IVRY_SUR_SEINE",
        "East Fork Jemez River",
        "B2 Desert Site Granite 1",
        "Marshall Gulch - Granite",
    ]

    print("Name normalization examples:\n")
    for name in test_names:
        print(f"  {name:50} → {normalize_site_name(name)}")
