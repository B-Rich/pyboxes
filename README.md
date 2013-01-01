
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

I intend the image to have no root password (since it can only be
reached from localhost), but at the moment the downloadable image may in
fact have `asdf` as its root password.  It's a long story.
