Role Name
=========

A brief description of the role goes here.

Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

tag_name: Name of the Wine tag at GitHub we are working with (ex: "v4.2")
winepak_runtime_version: Version of the winepak runtime to be used
wine_src_url: Url of the .tar.xz file containing the wine source code (Provided by the module get_wine_files_data)
wine_src_sha256: sha256 hash of the file at wine_src_url (Provided by the module get_wine_files_data)
wine_staging_url: Url of the .tar.gz file containing the wine staging patching scripts (Provided by the module get_wine_files_data)
wine_staging_sha256: sha256 hash of the file at wine_staging_url (Provided by the module get_wine_files_data)



Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
