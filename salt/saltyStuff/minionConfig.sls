saltyfleet_minion_config:
  file.managed:
    - name: /etc/salt/minion.d/saltyfleet.conf
    - user: root
    - group: wheel
    - mode: '0644'
    - contents: |
        file_client: local

        file_roots:
          base:
            - /opt/saltyfleet/salt

        pillar_roots:
          base:
            - /opt/saltyfleet/pillar

        grains_dirs:
          - /opt/saltyfleet/salt/_grains

        module_dirs:
          - /opt/saltyfleet/salt/_modules
