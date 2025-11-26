#!/usr/bin/env python3
"""
Get user information from the system.
Returns JSON with user details.
"""

import json
import os
import pwd
import sys

def get_user_info():
    """Get current user information."""
    try:
        # Get current user
        username = os.environ.get('USER', os.environ.get('USERNAME', ''))
        if not username:
            return {"error": "Could not determine username"}
        
        # Get user info from passwd
        user_info = pwd.getpwnam(username)
        
        # Parse GECOS field (full name, room, work phone, home phone, other)
        gecos_parts = user_info.pw_gecos.split(',')
        full_name = gecos_parts[0] if gecos_parts else username
        
        # Check for avatar in common locations
        home = user_info.pw_dir
        avatar_paths = [
            os.path.join(home, '.face'),
            os.path.join(home, '.face.icon'),
            os.path.join(home, '.local', 'share', 'pixmaps', 'faces', f'{username}.png'),
            os.path.join(home, '.local', 'share', 'pixmaps', 'faces', f'{username}.jpg'),
        ]
        
        # Check AccountsService with various extensions
        accounts_service_base = f'/var/lib/AccountsService/icons/{username}'
        for ext in ['', '.png', '.jpg', '.jpeg', '.gif', '.svg']:
            avatar_paths.append(accounts_service_base + ext)
        
        avatar_path = ""
        for path in avatar_paths:
            if os.path.isfile(path):
                avatar_path = path
                break
        
        return {
            "username": username,
            "fullName": full_name if full_name else username,
            "home": home,
            "shell": user_info.pw_shell,
            "uid": user_info.pw_uid,
            "gid": user_info.pw_gid,
            "avatarPath": avatar_path
        }
    
    except KeyError:
        return {"error": f"User '{username}' not found"}
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    result = get_user_info()
    print(json.dumps(result))
