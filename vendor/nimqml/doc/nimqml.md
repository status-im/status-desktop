:Authors:
	Filippo Cucchetto <filippocucchetto@gmail.com>

	Will Szumski <will@cowboycoders.org>
:Version: 0.7.7
:Date: 2019/10/01


Introduction
-----------
The NimQml module adds Qt Qml bindings to the Nim programming language
allowing you to create new modern UI by mixing the Qml declarative syntax
and the Nim imperative language.

You will need:
* The DOtherSide C++ shared library
* The NimQml Nim module

This first component implements the glue code necessary for
communicating with the Qt C++ library, the latter module wraps
the libDOtherSide exported symbols in Nim


Building the C++ DOtherSide bindings
--------
At the time of writing the DOtherSide C++ library must be compiled
and installed manually from source.

First clone the DOtherSide git repo
::
  git clone https://github.com/filcuc/DOtherSide

than you can proceed with the common CMake build steps

::
  mkdir build
  cd build
  cmake ..
  make
  make install
  

Installation of NimQml module
----------
The installation is not mandatory, in fact you could try
the built-in examples in the following way
::
  cd path/to/repo/nimqml
  cd examples/helloworld
  export LD_LIBRARY_PATH=path/to/libDOtherSide.so
  nim c -r main

Alternatively you can use the ``nimble`` package manager
::
  nimble install NimQml

or
::
  cd to/build/dir/Nim/NimQml
  nimble install


Example 1: HelloWorld
----------
As usual lets start with an HelloWorld example.
Most of the NimQml projects are made by one or more nim and qml
files. Usually the .nim files contains your app logic and data
layer. The qml files contain the presentation layer and expose
the data in your nim files.

``examples/helloworld/main.nim``

.. code-block:: nim
   :file: ../examples/helloworld/main.nim

``examples/helloworld/main.qml``

.. code-block:: qml
   :file: ../examples/helloworld/main.qml

The example shows the mandatory steps of each NimQml app
1. Create the ``QApplication`` for initializing the Qt runtime
2. Create the `QQmlApplicationEngine` and load your main .qml file
3. Call the `exec` proc of the QApplication instance for starting the Qt event loop

Example 2: exposing data to Qml
------------------------------------
The previous example shown how to startup the Qt event loop 
to create an application with a window.

It's time to explore how to pass data to Qml but lets see the
example code first:

``examples/simpledata/main.nim``

.. code-block:: nim
   :file: ../examples/simpledata/main.nim

``examples/simpledata/main.qml``

.. code-block:: qml
   :file: ../examples/simpledata/main.qml

The example shows how to expose simple values to Qml:
1. Create a `QVariant` and set its value.
2. Set a property in the Qml root context with a given name.

Once a property is set through the ``setContextProperty`` proc, it's available
globally in all the Qml script loaded by the current engine (see the official Qt
documentation for more details about the engine and context objects)

At the time of writing the QVariant class support the following types:
* int
* string
* bool
* float
* QObject derived classes

Example 3: exposing complex data and procedures to Qml
----------------------------------------------------------
As seen by the second example, simple data is fine. However most
applications need to expose complex data, functions and
update the view when something changes in the data layer.
This is achieved by creating an object that derives from QObject.

A QObject is made of :
1. ``slots``: functions that could be called from the qml engine and/or connected to Qt signals
2. ``signals``: functions for sending events and to which slots connect
3. ``properties``: properties allow the passing of data to the Qml view and make it aware of changes in the data layer

A QObject `property` is made of three things:
* a read slot: a method that returns the current value of the property
* a write slot: a method that sets the value of the property
* a notify signal: emitted when the current value of the property is changed

We'll start by looking at the main.nim file

``examples/slotsandproperties/main.nim``

.. code-block:: nim
   :file: ../examples/slotsandproperties/main.nim

We can see:
1. The creation of a Contact object
2. The injection of the Contact object to the Qml root context using the ``setContextProperty`` as seen in the previous example

The Qml file is as follows:

``examples/slotsandproperties/main.qml``

.. code-block:: qml
   :file: ../examples/slotsandproperties/main.qml

The qml is made up of: a Label, a TextInput widget, and a button.
The label displays the contact name - this automatically updates when
the contact name changes.

When clicked, the button updates the contact name with the text from
the TextInput widget.

So where's the magic?

The magic is in the Contact.nim file

``examples/slotsandproperties/contact.nim``

.. code-block:: nim
   :file: ../examples/slotsandproperties/contact.nim

A Contact is a subtype derived from `QObject`

Defining a `QObject` is done using the nim `QtObject` macro

.. code-block:: nim
  QtObject:
    type Contact* = ref object of QObject
    m_name: string

Inside the `QtObject` just define your subclass as your would normally do in Nim.

Since Nim doesn't support automatic invocation of base class constructors and destructors
you need to call manually the base class `setup` and `delete` functions.

.. code-block:: nim
  proc delete*(self: Contact) =
    self.QObject.delete

  proc setup(self: Contact) =
    self.QObject.setup

Don't forget to call the `setup` function and `delete` in your exported constructor
procedure

.. code-block:: nim
  proc newContact*(): Contact =
    new(result, delete)
    result.m_name = "InitialName"
    result.setup

The creation of a property is done in the following way:

.. code-block:: nim
  QtProperty[string] name:
    read = getName
    write = setName
    notify = nameChanged

A `QtProperty` is defined by a:
1. type, in this case `string`
2. name, in this case `name`
3. read slot, in this case `getName`
4. write slot, in this case `setName`
5. notify signal, in this case `nameChanged`

Looking at the ``getName`, `setName``, `nameChanged` procs, show  that slots and signals
are nothing more than standard procedures annotated with `{.slot.}` and `{.signal.}`


Example 4: ContactApp
-------------------------
The last example tries to show you all the stuff presented
in the previous chapters and gives you an introduction to how
to expose lists to qml.

Qt models are a huge topic and explaining in detail how they work is
out of scope. For further information please read the official
Qt documentation.

The main file follows the basic logic of creating a qml
engine and exposing a QObject derived object "ApplicationLogic"
through a global "logic" property

``examples/contactapp/main.nim``

.. code-block:: nim
   :file: ../examples/contactapp/main.nim

The qml file shows a simple app with a central tableview

``examples/contactapp/main.qml``

.. code-block:: qml
   :file: ../examples/contactapp/main.qml

The important things to notice are:
1. The menubar load, save and exit items handlers call the logic load, save and exit slots
2. The TableView model is retrieved by the logic.contactList property
3. The delete and add buttons call the del and add slots of the logic.contactList model

The ApplicationLogic object is as follows:

``examples/contactapp/applicationlogic.nim``

.. code-block:: nim
   :file: ../examples/contactapp/applicationlogic.nim

The ApplicationLogic object,
1. expose some slots for handling the qml menubar triggered signals
2. expose a contactList property that return a QAbstractListModel derived object that manage the list of contacts

The ContactList object is as follows:

``examples/contactapp/contactlist.nim``

.. code-block:: nim
   :file: ../examples/contactapp/contactlist.nim

The ContactList object:
1. overrides the ``rowCount`` method for returning the number of rows stored in the model
2. overrides the ``data`` method for returning the value for the exported roles
3. overrides the ``roleNames`` method for returning the names of the roles of the model. This name are then available in the qml item delegates
4. defines two slots ``add`` and ``del`` that add or delete a Contact. During this operations the model execute the ``beginInsertRows`` and ``beginRemoveRows`` for notifing the view of an upcoming change. Once the add or delete operations are done the model execute the ``endInsertRows`` and ``endRemoveRows``.
