# dClasses Documentation

`Current Version: v0.2.0`

dClasses is composed of two components- the `dClasses-Library` (which you do not interact with) and the `dClasses-Interface` (which you do). The interface folder is the core of dClasses, containing all of the scripts that allow you to instantiate, delete, and interact with your dClasses objects. These scripts are listed below:

## dClasses Caller Scripts

### `[Task] Object`
```
queue  : [QueueTag]
class  : [ElementTag<String>]
object : [ElementTag<String>]
```

The Object task will create a dClasses object from a class with the provided name (see below for section on defining classes), attach it to the provided queue with the given object name.

The name provided here is the one that will be used by all other dClasses tasks in the provided queue to refer exclusively to this object.

---

### `[Task] Method`
```
call   : [ElementTag<String>]
*args  : [Any]
```

The `Method` task will call a method in an object in a provided queue and run it. All of this information is extracted from the `call` definition which must always be formatted as such:

```
def.call:[Queue Object].[Object Name].[Method Name]
```
*See the beginner's guide for examples of the `call` argument in use in a regular script.*

Method will also take any number of arguments following `def.call` to satisfy any required definitions that the provided method may have.

---

### `[Task] SetAttribute`
```
call  : [ElementTag<String>]
value : [ObjectTag]
```

The `SetAttribute` task will set the value of a public attribute in an objcet in a provided queue to the value provided in the `value` definition. The format for `def.call` in `SetAttribute` will always be as follows:

```
def.call:[Queue Object].[Object Name].[Attribute Name]
```
*See the beginner's guide for examples of the `call` argument in use in a regular script.*

---

### `[Task] DestroyObject`
```
call : [ElementTag<String>]
```

The `DestroyObject` task will delete all references of the object provided in the `call` argument at the queue and server levels. The format for `def.call` in `DestroyObject` will always be as follows:

```
def.call:[Queue Object].[Object Name]
```
*See the beginner's guide for examples of the `call` argument in use in a regular script.*

---

### `[Proc] GetAttribute`
```
call : [ElementTag<String>]
```

The `GetAttribute` task will get the value of a public attribute in an object in a provided queue. The format for `def.call` in `GetAttribute` will always be as follows:

```
def.call:[Queue Object].[Object Name].[Attribute Name]
```
*See the beginner's guide for examples of the `call` argument in use in a regular script.*

## dClasses Special Methods

Every dClasses object will come built-in with a number of 'special' methods that control certain core aspects of how a dClasses object behaves. These methods can be accessed in the same way that a normal user-defined method is accessed.

Some of these special methods are 'dynamic' meaning that their behaviour can be changed and overridden if the user defines a method with one of their names.

---

### `[Method] __delattr (Static)`

Functionally identical to simply deleting an attribute from inside a class. However, `__delattr` can be called from outside a class. The primary (and obvious) limitation is that `__delattr` can only be used to delete public attributes.

---

### `[Method] __class (Static)`

Gets the name of the class that the provided object is instantiated from.

---

### `[Method] __str (Dynamic)`

Returns a stringified representation of the provided object. By default, this method will return the provided object's binary representation.

---

### `[Method] __eq (Dynamic)`
```
*args : [Any]
```

Returns true if the provided object is equal to the first argument provided to this method. By default, this method will compare the binary representations of each provided dClasses object.

---

### `[Method] __len (Dynamic)`

Returns the length of the dClasses object. By default, this method will return the length of the object's binary representation.

---

### `[Method] __hash (Dynamic)`

Returns the unique hash relevant to the provided dClasses object. By default, this method will return the unique dClasses hash that was generated for the provided object on instantiation.

## dClasses Special Scripts

dClasses also comes built-in with some stand-alone scripts that make working the specialized dClasses objects a bit easier.

---

### `[Proc] IsInstance`
```
call  : [ElementTag<String>]
class : [ElementTag<String>]
```

This procedure will return true if the dClasses object found at the location provided in the `call` definition is an instance of the class with the provided name. The format for `def.call` in `IsInstance` will always be as follows:

```
<proc[IsInstance].context[<element[[Queue Object].[Object Name]]>|[Class Name]]>
```
*See the beginner's guide for examples of the `call` argument in use in a regular script.*

---

### `[Proc] IsClass`
```
object : [Union[ BinaryTag / MapTag ]]
```

This procedure will return true if the provided object is a valid dClasses object.

---

### `[Proc] GetObjectRef`
```
call : [ElementTag<String>]
```

This procedure will return a binary-encoded copy of the dClasses object found at the location provided in the `call` definition. The format for `def.call` in `GetObjectRef` will always be as follows:

```
<proc[IsInstance].context[<element[[Queue Object].[Object Name]]>]>
```
*See the beginner's guide for examples of the `call` argument in use in a regular script.*

---

### `[Task] MakeObjectRef`
```
queue      : [QueueTag]
objectName : [ElementTag<String>]
object     : [Union[ MapTag / BinaryTag ]]
```

This task will create a queue-level reference for the provided raw dClassObject provided under the provided name as if it were instantiated by `Object`.

This task is useful for cases where methods need to have a raw dClassObject be passed in.
