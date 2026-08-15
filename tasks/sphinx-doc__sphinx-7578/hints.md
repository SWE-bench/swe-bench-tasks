I have reconfirmed that e5192ba48b45576e636e7dce82ad9183051443ed causes the bug. Before that commit I get no warnings and:

![Screenshot from 2020-04-27 11-01-04](https://user-images.githubusercontent.com/2365790/80387480-b0af0500-8876-11ea-8b98-01a76fe425f9.png)

After that commit:

![Screenshot from 2020-04-27 11-03-37](https://user-images.githubusercontent.com/2365790/80387553-c58b9880-8876-11ea-80b4-8939a1997f3c.png)

Here is the minimal example, just unzip and run `make`:

[tinybuild.zip](https://github.com/sphinx-doc/sphinx/files/4540401/tinybuild.zip)

Thank you for letting me know. This must be a bug!