{% set user = pillar['user']['primary_user'] %}

# -----------------------------
# zsh enviroment
# -----------------------------

# Ensure ~/.zshrc exists (do NOT manage full contents)
zshrc_exists:
  file.touch:
    - name: /Users/{{ user }}/.zshrc
    - contents: ""
    - mode: '0644'
    - user: {{ user }}
    - group: staff

# Core zsh configuration
zshrc_core:
  file.blockreplace:
    - name: /Users/{{ user }}/.zshrc
    - marker_start: "# --- SALT MANAGED ZSH CORE START ---"
    - marker_end: "# --- SALT MANAGED ZSH CORE END ---"
    - append_if_not_found: True
    - content: |
        # Load colors
        autoload -Uz colors
        colors

        # Colored prompt: cyan user@host, white full path
        PROMPT='%B%F{cyan}%n@%m%f%b:%B%F{white}%~%f%b$ '

        # Disable bracketed paste
        unset zle_bracketed_paste


# Salt workflow aliases
zshrc_salt_aliases:
  file.blockreplace:
    - name: /Users/{{ user }}/.zshrc
    - marker_start: "# --- SALT MANAGED SALT ALIASES START ---"
    - marker_end: "# --- SALT MANAGED SALT ALIASES END ---"
    - append_if_not_found: True
    - content: |
        # macOS Salt workflow aliases

        alias mac-check_build_state='sudo /usr/local/sbin/salt-call --local state.apply saltenv=base --file-root="/Users/{{ user }}/Documents/salting-macOS/salt" --pillar-root="/Users/{{ user }}/Documents/salting-macOS/pillar" test=true'

        alias mac-apply_build_state='sudo /usr/local/sbin/salt-call --local state.apply saltenv=base --file-root="/Users/{{ user }}/Documents/salting-macOS/salt" --pillar-root="/Users/{{ user }}/Documents/salting-macOS/pillar" test=false'
