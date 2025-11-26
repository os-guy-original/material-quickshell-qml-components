#!/usr/bin/env python3
"""
Desktop Application Scanner - Streaming version
Implements Freedesktop Desktop Entry Specification (DES)
Outputs apps as they're found for faster UI updates
"""

import os
import sys
import json
from pathlib import Path
from configparser import ConfigParser

def get_search_paths():
    """Get all application search paths"""
    paths = []
    
    # XDG paths
    xdg_data_home = os.environ.get('XDG_DATA_HOME', os.path.expanduser('~/.local/share'))
    xdg_data_dirs = os.environ.get('XDG_DATA_DIRS', '/usr/local/share:/usr/share')
    
    # Add user applications
    user_apps = Path(xdg_data_home) / 'applications'
    if user_apps.is_dir():
        paths.append(user_apps)
    
    # Add system applications
    for dir_path in xdg_data_dirs.split(':'):
        app_dir = Path(dir_path) / 'applications'
        if app_dir.is_dir():
            paths.append(app_dir)
    
    # Flatpak
    flatpak_user = Path.home() / '.local/share/flatpak/exports/share/applications'
    if flatpak_user.is_dir():
        paths.append(flatpak_user)
    
    flatpak_system = Path('/var/lib/flatpak/exports/share/applications')
    if flatpak_system.is_dir():
        paths.append(flatpak_system)
    
    # Snap
    snap_apps = Path('/var/lib/snapd/desktop/applications')
    if snap_apps.is_dir():
        paths.append(snap_apps)
    
    return paths

def parse_desktop_file(file_path):
    """Parse a .desktop file and return app data"""
    try:
        parser = ConfigParser(interpolation=None)
        parser.read(file_path, encoding='utf-8')
        
        if not parser.has_section('Desktop Entry'):
            return None
        
        section = parser['Desktop Entry']
        
        # Validate per DES requirements
        if section.get('Type') != 'Application':
            return None
        
        if section.get('NoDisplay', '').lower() == 'true':
            return None
        
        if section.get('Hidden', '').lower() == 'true':
            return None
        
        name = section.get('Name', '').strip()
        exec_cmd = section.get('Exec', '').strip()
        
        if not name or not exec_cmd:
            return None
        
        app_id = file_path.stem
        
        return {
            'id': app_id,
            'name': name,
            'genericName': section.get('GenericName', '').strip(),
            'comment': section.get('Comment', '').strip(),
            'icon': section.get('Icon', '').strip(),
            'exec': exec_cmd,
            'terminal': section.get('Terminal', '').lower() == 'true',
            'categories': section.get('Categories', '').strip().rstrip(';'),
            'filePath': str(file_path)
        }
    except Exception:
        return None

def main():
    """Scan and output applications as JSON array"""
    seen = set()
    apps = []
    
    for search_dir in get_search_paths():
        try:
            for desktop_file in search_dir.glob('*.desktop'):
                if not desktop_file.is_file():
                    continue
                
                app_id = desktop_file.stem
                if app_id in seen:
                    continue
                
                seen.add(app_id)
                app_data = parse_desktop_file(desktop_file)
                
                if app_data:
                    apps.append(app_data)
        except Exception:
            continue
    
    # Output as JSON array
    print(json.dumps(apps, ensure_ascii=False))

if __name__ == '__main__':
    main()
