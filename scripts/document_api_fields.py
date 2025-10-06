#!/usr/bin/env python3
"""
Document all available fields from each API endpoint
This will help us understand what data is available and plan our hierarchical retrieval
"""

import json
import requests
from typing import Dict, Set, Any, List
from datetime import datetime

# Configuration
API_URL = "https://vgw1-01.dal-interurban.mdu.attwifi.com"
API_KEY = "xWCH1KHxwjHRZtNbyBDTrGQw1gDry98ChcXM7bpLbKaTUHZzUUBsCb77SHrJNHUKGLAKgmykxsxsAg6r"

def extract_all_fields(data: Any, prefix: str = "") -> Set[str]:
    """Recursively extract all field names from JSON data"""
    fields = set()
    
    if isinstance(data, dict):
        for key, value in data.items():
            field_name = f"{prefix}.{key}" if prefix else key
            fields.add(field_name)
            
            # Recurse for nested objects
            if isinstance(value, dict):
                nested_fields = extract_all_fields(value, field_name)
                fields.update(nested_fields)
            elif isinstance(value, list) and value:
                # Check first item in list
                if isinstance(value[0], dict):
                    nested_fields = extract_all_fields(value[0], field_name + "[0]")
                    fields.update(nested_fields)
    
    return fields

def analyze_endpoint(endpoint_name: str, endpoint_path: str) -> Dict:
    """Analyze a single endpoint and document all fields"""
    print(f"\nAnalyzing {endpoint_name}...")
    
    headers = {
        'Authorization': f'Bearer {API_KEY}',
        'Accept': 'application/json'
    }
    
    try:
        # Fetch with page_size=0 to get all data
        url = f"{API_URL}{endpoint_path}?page_size=0"
        response = requests.get(url, headers=headers, timeout=60)
        response.raise_for_status()
        
        data = response.json()
        
        # Normalize response
        if isinstance(data, list):
            items = data
        elif isinstance(data, dict) and 'results' in data:
            items = data['results']
        else:
            items = [data] if data else []
        
        # Collect all unique fields across all items
        all_fields = set()
        field_values = {}  # Track sample values for each field
        field_types = {}   # Track data types
        
        for item in items[:10]:  # Analyze first 10 items for efficiency
            if isinstance(item, dict):
                fields = extract_all_fields(item)
                all_fields.update(fields)
                
                # Collect sample values and types
                for field in fields:
                    if field not in field_values:
                        # Navigate to the field value
                        parts = field.split('.')
                        value = item
                        try:
                            for part in parts:
                                if '[' in part:
                                    # Handle array notation
                                    base_part = part.split('[')[0]
                                    value = value[base_part][0]
                                else:
                                    value = value[part]
                            
                            field_values[field] = value
                            field_types[field] = type(value).__name__
                        except (KeyError, IndexError, TypeError):
                            field_values[field] = None
                            field_types[field] = 'unknown'
        
        # Categorize fields
        top_level_fields = {f for f in all_fields if '.' not in f and '[' not in f}
        nested_fields = all_fields - top_level_fields
        
        return {
            'endpoint': endpoint_name,
            'path': endpoint_path,
            'total_items': len(items),
            'total_fields': len(all_fields),
            'top_level_fields': sorted(top_level_fields),
            'nested_fields': sorted(nested_fields),
            'field_types': field_types,
            'sample_values': field_values
        }
        
    except Exception as e:
        print(f"  Error: {e}")
        return {
            'endpoint': endpoint_name,
            'path': endpoint_path,
            'error': str(e)
        }

def generate_documentation():
    """Generate comprehensive API field documentation"""
    print("="*80)
    print("API FIELD DOCUMENTATION GENERATOR")
    print(f"Timestamp: {datetime.now().isoformat()}")
    print("="*80)
    
    # Define endpoints to analyze
    endpoints = [
        ('rooms', '/api/pms_rooms.json'),
        ('access_points', '/api/access_points.json'),
        ('switches', '/api/switch_devices.json'),
        ('media_converters', '/api/media_converters.json'),
        ('wlan_controllers', '/api/wlan_devices.json')
    ]
    
    documentation = {}
    
    for name, path in endpoints:
        result = analyze_endpoint(name, path)
        documentation[name] = result
        
        if 'error' not in result:
            print(f"  ✓ Found {result['total_fields']} fields in {result['total_items']} items")
        else:
            print(f"  ✗ Error: {result['error']}")
    
    # Generate markdown documentation
    markdown = generate_markdown(documentation)
    
    # Save to file
    doc_path = '/home/scl/Documents/rgnets-field-deployment-kit/docs/api_fields_reference.md'
    with open(doc_path, 'w') as f:
        f.write(markdown)
    
    print(f"\n📄 Documentation saved to: docs/api_fields_reference.md")
    
    return documentation

def generate_markdown(documentation: Dict) -> str:
    """Generate markdown documentation from field analysis"""
    md = []
    
    md.append("# API Fields Reference")
    md.append(f"\nGenerated: {datetime.now().isoformat()}")
    md.append(f"\nAPI URL: `{API_URL}`")
    md.append("\n## Overview")
    md.append("\nThis document lists all available fields for each API endpoint when called with `page_size=0`.")
    
    # Summary table
    md.append("\n## Summary")
    md.append("\n| Endpoint | Path | Total Items | Total Fields |")
    md.append("|----------|------|-------------|--------------|")
    
    for name, info in documentation.items():
        if 'error' not in info:
            md.append(f"| {name} | `{info['path']}` | {info['total_items']} | {info['total_fields']} |")
    
    # Detailed field listings
    for name, info in documentation.items():
        if 'error' in info:
            continue
            
        md.append(f"\n## {name.replace('_', ' ').title()}")
        md.append(f"\n**Endpoint:** `{info['path']}`")
        md.append(f"\n**Total Items:** {info['total_items']}")
        md.append(f"\n**Total Fields:** {info['total_fields']}")
        
        # Top-level fields
        md.append("\n### Top-Level Fields")
        md.append("\n| Field | Type | Sample Value |")
        md.append("|-------|------|--------------|")
        
        for field in info['top_level_fields']:
            field_type = info['field_types'].get(field, 'unknown')
            sample = info['sample_values'].get(field)
            
            # Format sample value
            if sample is None:
                sample_str = "null"
            elif isinstance(sample, str):
                sample_str = f'"{sample[:50]}"' if len(sample) > 50 else f'"{sample}"'
            elif isinstance(sample, (list, dict)):
                sample_str = f"{type(sample).__name__}"
            else:
                sample_str = str(sample)
            
            md.append(f"| `{field}` | {field_type} | {sample_str} |")
        
        # Nested fields (if any)
        if info['nested_fields']:
            md.append("\n### Nested Fields")
            md.append("\n| Field Path | Type |")
            md.append("|------------|------|")
            
            for field in info['nested_fields'][:20]:  # Limit to first 20 for readability
                field_type = info['field_types'].get(field, 'unknown')
                md.append(f"| `{field}` | {field_type} |")
            
            if len(info['nested_fields']) > 20:
                md.append(f"\n*... and {len(info['nested_fields']) - 20} more nested fields*")
        
        # Recommended fields for different use cases
        md.append("\n### Recommended Field Sets")
        
        # Determine recommended fields based on endpoint
        if 'access_point' in name or 'switch' in name or 'media_converter' in name or 'wlan' in name:
            md.append("\n**For Summary/List View:**")
            md.append("```")
            md.append("only=id,name,online,mac_address,ip_address,model")
            md.append("```")
            
            md.append("\n**For Detail View (additional fields):**")
            md.append("```")
            md.append("only=id,name,online,mac_address,ip_address,model,serial_number,firmware_version,last_seen,created_at,updated_at")
            md.append("```")
        
        elif 'room' in name:
            md.append("\n**For Summary/List View:**")
            md.append("```")
            md.append("only=id,name,room,building,floor,access_points,media_converters")
            md.append("```")
            
            md.append("\n**For Detail View (all fields):**")
            md.append("```")
            md.append("# Use without 'only' parameter to get all fields")
            md.append("```")
    
    md.append("\n## Performance Optimization Strategy")
    md.append("\n### Hierarchical Data Loading")
    md.append("\n1. **Initial Load (< 500ms):** Fetch minimal fields for counts and summary")
    md.append("2. **List View Load (< 2s):** Fetch fields needed for list display")
    md.append("3. **Detail Load (on-demand):** Fetch complete data when user views details")
    
    md.append("\n### Example Usage")
    md.append("\n```bash")
    md.append("# Step 1: Quick summary")
    md.append("GET /api/access_points.json?page_size=0&only=id,name,online")
    md.append("\n# Step 2: List view data")
    md.append("GET /api/access_points.json?page_size=0&only=id,name,online,mac_address,ip_address,model")
    md.append("\n# Step 3: Full details (on demand)")
    md.append("GET /api/access_points/{id}.json")
    md.append("```")
    
    return '\n'.join(md)

if __name__ == "__main__":
    generate_documentation()