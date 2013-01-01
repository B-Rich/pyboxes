
PyBoxes
=======

The goal of the PyBoxes project is to offer a collection of VirtualBox
“appliance images” (known as `.ova` files) that, when booted, offer an
iPython Notebook session with whole collections of popular libraries
already installed.

My hope is to lower the barrier-to-entry that people face when they want
to try out the Python language with a library like PyEphem that requires
separate compilation.  I have spent many hours trying to help Mac and
Windows users who cannot successfully install any new Python packages
because years of poor install instructions have finally damaged their
system Python to the point that it can no longer run a new `setup.py`
and this project hopes to do an end-run around self-installed Python by
offering clean virtual machines instead.

The first experimental image is available at:

http://pyboxes.s3.amazonaws.com/PyEphem.ova

When the virtual machine has finished booting inside of VirtualBox, the
user should be able to visit its iPython Notebook by pointing their web
browser (assuming that the browser is running on the same machine as
VirtualBox) at:

http://127.0.0.1:8888/

This image not only has SciPy and Matplotlib installed, but also the
PyEphem astronomy library.  At the moment I am experimenting with using
Arch Linux as the base operating system because of its simplicity (and
its fairly pristine Python install when compared to Ubuntu!).

Technical Specifications
------------------------

    SOFTWARE

    Arch Linux as the base system
    OpenSSH daemon for optional administration
    iPython Notebook as the main application

    LIBRARIES

    iPython
    PyEphem
    matplotlib
    numpy
    scipy

    SECURITY

    Virtual box is behind NAT
    Virtual box has no permission to access your system

    PORT FORWARDS

    Port 2022 → 22
        In case you want to log in and look around:

            ssh -p 2022 root@127.0.0.1

        The root password is currently "asdf" because SSH
        was requiring there to be *some* password.

    Port 8888 → 8888
        So users can visit http://127.0.0.1:8888/ in their
        browser and access iPython Notebook

TODO
----

* Add some kind of version number.
* Add a welcome page describing the software present.
* Add documentation about how to install more software.
* Add documentation about downloading astronomy data files.
* Add PyTables.
* Fully automate the install so that it is fully reproducible.
* Change port forwards to bind specifically to localhost so that other
  people sitting in a coffee shop cannot access the iPython console or
  SSH port.
