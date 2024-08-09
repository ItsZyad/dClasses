# dClasses : Object Orientation in Denizen

`Current Version: v0.2.0`

Welcome to dClasses, an attempt to add robust and standardized tools for OOP-style programming to Denizen!

To get started download the code from here (or from dClasses' forum page[insert link]) and drag it into your server's `plugins/Denizen/scripts` folder. It is recommended that you keep dClasses in its own sub-folder inside `scripts/`.

If you need guidance for first-time usage, there is a short beginner's guide below. For all further documentation, please check the dedicated Documentation file. Additionally, I've attached a full-fledged sample class that (tries) to take advantage of all the features dClasses has to offer in the `SampleClass.dsc` file.

---
### **Important Notices!**

1. As of now, this project is still in beta. It is to be expected to have instances where things don't work as expected as there are a lot of moving parts to dClasses. I will attempt to keep updating this repo to the best of my abilities and iron out any issues as I become aware of them.

2. There will almost certainly be changes to either the names or parameters of some of dClasses' core scripts like `Object`, so bear this in mind before using dClasses, in its current state, in any important project.

    As soon as I'm confident that there won't be any changes to dClasses API-side, I will remove this notice.

3. There is currently a quirk in dClasses which can cause two methods with the same name but different access modifiers to be registered as two different methods. This is a known bug and I'll work on it whenever I'm free. It is not recommended to build any important scripts on top of this ""feature"". If you do so, know that it can and will be patched out eventually.

# Beginner's Guide

*Note: This guide will assume that you are familiar with at least the basic terminology surrounding OOP. If you have no idea how OOP works in regular programming languages and the design patterns surrounding it, then I recommend reading/watching a short tutorial on that (Like W3 Schools' Java or Python OOP guides which you can find [\[Here\]](https://www.w3schools.com/java/java_oop.asp) and [\[Here\]](https://www.w3schools.com/python/python_classes.asp) respectively).*

## Defining a Class in dClasses

All classes in dClasses are contained within data scripts where the only top-level key is `class`, like so:

```DenizenScript
SampleStudent_Class:
    type: data

    class:
        ...
```

The most important sub-key inside `class:` will be `methods:`. Class methods are formatted exactly as you would format a regular Denizen task script, having a `definitions` key and a `script` key. The only difference being- it all being contained within the data script.

Most classes should have at least one method- that being the constructor. A constructor tells your class what to do each time it is instantiated;

```DenizenScript
SampleStudent_Class:
    type: data

    class:
        methods:
            constructor:
                definitions: name|grade|age|school
                script:
                - narrate "some code here"
```

Now, let's talk about attributes. While dClasses method definitions are baked directly into the data script, attributes are defined *inside* the methods.

For dClasses to recognize a definition as an object attribute (as opposed to just a regular definition) its name must be preceeded by an asterisk. The number of astrisks before a definition's name denotes its access permissions; one asterisk means the attribute is public, two means it's private, and three means it's protected.

If you are familiar with programming in Java, then this system should not be alien to you. However, if you're not familiar with access permissions in traditional OOP, then it's quite straight-forward. Public attributes are attributes that can be accessed from inside and outside the class. Private attributes can only be accessed from inside the class. While protected attributes can be accessed from inside the class and any other class that inherits from it (we'll get to inheritence later).

Let's build off of `SampleStudent_Class` and add some attributes to it:

```DenizenScript
SampleStudent_Class:
    type: data

    class:
        methods:
            constructor:
                definitions: name|grade|age|school
                script:
                - define *name <[name]>
                - define *grade <[grade]>
                - define *age <[age]>
                - define *school <[school]>
```

## Instantiation

This class now has four attributes- all of them public. dClasses has two built-in scripts `GetAttribute` and `SetAttribute` that allow you to do just what you'd imagine they'd do- get the value of, and set the value of a given attribute inside a given object. But to use them you first need to instantiate the class. Instantiation is the process of duplicating a class with a set of given parameters (usually those specified in the constructor method) and placing it in active memory. To do this in dClasses, you run the `Object` script.

```DenizenScript
- run Object def.queue:<queue> def.class:SampleStudent_Class def.object:newStudent
```

What command, above, just did is create a new object from the class `SampleStudent_Class` with the name `newStudent`. The reason why you also pass in the current queue is because dClasses objects are attached directly to the queue they are instantiated in as a flag. This way, you don't need to pass around any definitions or server-level flags to interact with your dClasses objects. You simply give them a name, and that name is valid for the queue you're working in.

---

**Quick Sidebar**

*There **are** still ways to grab a reference of dClasses objects as a raw binary for storage as a regular definition or flag. Check the documentation for more info that.*

---

But before you can run the command above you must make sure you've done one more thing. You must attach the definitions of all the parameters you've set in your constructor. In this case, those are: `name`, `grade`, `age`, and `school`:

```DenizenScript
- run Object def.queue:<queue> def.class:SampleStudent_Class def.object:newStudent def.name:John def.grade:9 def.age:14 def.school:Test_High
```

## Working With Attributes

Now that we've instantiated the class into our current queue, we can start getting and setting attributes. To do that with public attributes (like in our sample class), we can use the afforementioned `GetAttribute` and `SetAttribute` scripts. For example, if I wanted to have our student graduate to the next grade then I could do something like this:

```DenizenScript
- run SetAttribute def.call:<queue>.newStudent.*grade def.value:10
- run SetAttribute def.call:<queue>.newStudent.*age def.value:15
```

Now, you will notice that the syntax for `SetAttribute` is slightly different than that of `Object`. That is because `SetAttribute` utilizes dot-notation to indicate the exact location of the attribute they're trying to manipulate under a definition called `call`. The `call` definition will always follow this exact format:

`def.call:<queue>.[object name].[attribute name]`

`GetAttribute` is a procedure, and so it will be called from the `<proc>` tag, but it follows the exact same format as `SetAttribute`:

```DenizenScript
- narrate <proc[GetAttribute].context[<queue>.newStudent.*age]>
```

### A Little More on Access Modifiers

The class we defined above is consisted solely of public attributes and methods, but what if we wanted to lock access to some attributes such that they can only be freely modified inside the class (or its subclasses). To do that, we use double asterisks for private attributes and triple asterisks for protected attributes;

```DenizenScript
SampleStudent_Class:
    type: data

    class:
        methods:
            constructor:
                definitions: name|grade|age|school
                script:
                - define *name <[name]>
                - define **grade <[grade]>
                - define ***age <[age]>
                - define *school <[school]>
```

Here, we've made `grade` a private attribute and `age` a protected attribute. This means that neither one can be accessed using `Get/SetAttribute` outside of the class. We will need to write getters and setters for them;

```DenizenScript
SampleStudent_Class:
    type: data

    class:
        methods:
            constructor:
                definitions: name|grade|age|school
                script:
                - define *name <[name]>
                - define **grade <[grade]>
                - define ***age <[age]>
                - define *school <[school]>
            
            GetGrade:
                script:
                - determine <[**grade]>

            SetGrade:
                definitions: newGrade
                script:
                - define **grade <[newGrade]>

            GetAge:
                script:
                - determine <[***age]>

            AddAge:
                script:
                - define ***age:++
```

In this case, there really is no purpose to have the grade attribute set up the way that it is since, generally, the main reason to have an attribute be set as either private or protected is to control the way that the attribute is accessed and set. But as you can see, that is exactly what we do with `***age`. Since it's impossible for you to get younger, there is no 'SetAge' method, only an `AddAge` method which increments the `***age` attribute by one.

*Of course there are design reasons for why you probably wouldn't have a real 'Student' class set up in this way, but you get the idea...*

### The `**self` definition

As already established, if you want to run a method from a class that you just instantiated, all you need to do is call the `Method` task with the name of the object you just created. However, what if you wanted to call a method from inside a class? What name do you use? Well, much like in a language like Python, dClasses has a `self` keyword that is automatically passed into all class methods (although here `self` will act as a private definition as opposed to a keyword).

So if I wanted to run the `SetGrade` method in out example `SampleStudent_Class`, all I would need to do is:

```DenizenScript
SampleStudent_Class:
    type: data

    class:
        methods:
            constructor:
                definitions: name|grade|age|school
                script:
                - define *name <[name]>
                - define ***age <[age]>
                - define *school <[school]>

                - run Method def.call:<queue>.**self.SetGrade def.newGrade:<[grade]>

            GetGrade:
                script:
                - determine <[**grade]>

            SetGrade:
                definitions: newGrade
                script:
                - define **grade <[newGrade]>

            GetAge:
                script:
                - determine <[***age]>

            AddAge:
                script:
                - define ***age:++
```

### Class Attributes

If you've ever worked with Python classes before then you are likely familiar with how class attributes work. While object attributes can differ between different instances of the same class, class attributes can be set in any instance but will have the same value across all instances. If we return the student class example but add the `attributes` key to the class:

```DenizenScript
SampleStudent_Class:
    type: data

    class:
        attributes:
            allStudents: <list[]>

        methods:
            constructor:
                definitions: name|grade|age|school
                script:
                - define *name <[name]>
                - define **grade <[grade]>
                - define ***age <[age]>
                - define *school <[school]>
            
                - define ^allStudents:->:<proc[GetClassRef].context[<queue>|**self]>

            GetGrade:
                script:
                - determine <[**grade]>

            SetGrade:
                definitions: newGrade
                script:
                - define **grade <[newGrade]>

            GetAge:
                script:
                - determine <[***age]>

            AddAge:
                script:
                - define ***age:++
```

The `class.attributes` key allows you to define the default value of any global attributes associated wtith the class. The first time a class is initialized, all of the global attributes defined here are assigned their default value. However if another instance of the class is created the default value will not be set again since it already exists.

To change the value of global attribute you can access it from within any of the class' methods using the `^` (carat) prefix as shown in the example above.

*Note: the `GetClassRef` procedure simply returns a binary representation of the class with the provided name in the provided queue. You can find its full explanation in the documentation.md file.*

## Working With Methods

While this guide has already introduced the basic usage of methods in dClasses - through previous examples showcasing the setters and getters of private and protected attributes - it is still important to go through the inner workings of dClasses methods on their own.

For starters, method access modifiers are slightly different to their attribute counterparts. Since the YAML parser that Denizen uses doesn't like it when keys begin with asterisks, the access modifiers all start with tildes:

`~*`  : Private

`~**` : Protected

Secondly, all previous rules relating to the `**self` keyword outlined in the previous sub-section also apply to methods. In other words, any method can be run by any other method inside the same class.

Finally, to run a method, you can simply use the `Method` script and pass in arguments much like you would for the `Set/GetAttribute` tasks- with a `def.call` argument as well as any other user-defined arguments that the method may need to run;

```DenizenScript
- run Method def.call:<queue>.[object-name].[method-name] def.otherDef:<element[hello world]>
```

---
**Important Note**

Just to reiterate one of the notices from above--

There is currently a quirk in dClasses which can cause two methods with the same name but different access modifiers to be registered as two different methods. Since this bug does not (to the best of my knowledge) have any _outright_ adverse consequences I have chosen to deprioritize it in favor of fixing other, more pressing, bugs. As long as this notice exists, know that this bug also does.

It is not recommended to build any important scripts on top of this ""feature"". It will likely be patched out sooner than later.


## Inheritence

dClasses allows for classes to inherit from other classes by adding the `extends` key to the class' data script like so:

```DenizenScript
SamplePerson_Class:
    type: data
    
    class:
        methods:
            constructor:
                definitions: name|age
                script:
                - define ***name <[name]>
                - define ***age <[age]>

            GetAge:
                script:
                - determine <[***age]>

            SetAge:
                definitions: newAge
                script:
                - define ***age <[newAge]>


SampleStudent_Class:
    type: data

    class:
        extends: SamplePerson_Class
        attributes:
            allStudents: <list[]>

        methods:
            constructor:
                definitions: name|age|grade|school
                script:
                - define **grade <[grade]>
                - define *school <[school]>
            
                - define ^allStudents:->:<proc[GetClassRef].context[<queue>|**self]>

            GetGrade:
                script:
                - determine <[**grade]>

            SetGrade:
                definitions: newGrade
                script:
                - define **grade <[newGrade]>

            AddAge:
                script:
                - define ***age:++
```

In this example, we have created a parent class for `SampleStudent_Class` which includes just age and name data. You will also notice that both of these attributes have been made to be protected, allowing them to be accessed from the child class.

Unlike in regular OOP, all child classes will automatically run the constructor method of the parent class with the provided definitions when they are instantiated. To override the definitions established in the parent class, you can simply redefine the given attributes in the child class' constructor method.

### Polymorphism

dClasses supports polymorphic design patterns by default. All methods in child classes will automatically overwrite any methods in their parent class with the same name.