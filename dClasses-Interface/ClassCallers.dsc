Object:
    type: task
    debug: false
    definitions: queue[`QueueTag`]|class[`ElementTag(String)`]|object[`ElementTag(String)`]
    description:
    - Instantiates the class with the given name as a dClasses object in the provided queue.
    - The name provided to the object will be the one referred to it by any other dClasses script in the given queue.
    - Will return null if the action fails.
    - ---
    - → [Void]

    script:
    ## Instantiates the class with the given name as a dClasses object in the provided queue.
    ## The name provided to the object will be the one referred to it by any other dClasses script
    ## in the given queue.
    ##
    ## Will return null if the action fails.
    ##
    ## queue  : [QueueTag]
    ## class  : [ElementTag(String)]
    ## object : [ElementTag(String)]
    ##
    ## >>> [Void]

    - define passedParams <queue.definition_map.exclude[queue|object|class]>

    - if !<[queue].is_valid>:
        - run dClassesError def.queue:<queue> def.silent:false def.message:INVALID_QUEUE_ERROR
        - determine null

    - if !<util.scripts.contains[s<&at><[class].to_lowercase>]>:
        - run dClassesError def.queue:<queue> def.silent:false def.message:<element[Unable to instantiate from class name: <[class].color[red]>. No class by that name exists!]>
        - determine null

    - define classScript <script[<[class]>]>

    - if !<[classScript].container_type> == data || !<[classScript].data_key[class].exists>:
        - run dClassesError def.queue:<queue> def.silent:false def.message:<element[Unable to instantiate a class from script: <[class].color[red]>. That script is not initialized as a class.]>
        - determine null

    - define objectMap.class:<[class]>
    - define objectMap.queue:<[queue]>
    - define objectMap.attrs.public.list:<map[]>
    - define objectMap.attrs.private.list:<map[]>
    - define objectMap.attrs.protected.list:<map[]>

    - define objectMap.methods.public.list:<map[]>
    - define objectMap.methods.private.list:<map[]>
    - define objectMap.methods.protected.list:<map[]>

    - flag server dClasses.<[class]>.globalAttributes.list:<map[]>

    ## CASE: Has global attributes
    - if <[classScript].data_key[class.attributes].exists>:
        - define objectMap.classAttrs:<[classScript].data_key[class.attributes].keys.parse_tag[^<[parse_value]>]>

        - foreach <[classScript].data_key[class.attributes]>:
            # Skip redefinition if the global attr already exists
            - if <server.has_flag[dClasses.<[class]>.globalAttributes.list.<element[^<[key]>]>]>:
                - foreach next

            - flag server dClasses.<[class]>.globalAttributes.list.<element[^<[key]>]>:<[value].parsed>

    ## CASE: Extends another class
    - if <[classScript].data_key[class.extends].exists>:
        - define objectMap.extends:<[classScript].data_key[class.extends]>
        - definemap parentClassDefMap:
            queue: <queue>
            object: parentClass
            class: <[classScript].data_key[class.extends]>

        - define parentClassDefMap <[parentClassDefMap].include[<[passedParams]>]>

        - run Object defmap:<[parentClassDefMap]>

        - define decodedParentClass <queue.flag[dClasses.parentClass].proc[DecodeClass]>
        - define objectMap.attrs.protected:<[decodedParentClass].deep_get[attrs.protected]>
        - define objectMap.attrs.public:<[decodedParentClass].deep_get[attrs.public]>

        - define objectMap.methods.protected:<[decodedParentClass].deep_get[methods.protected]>
        - define objectMap.methods.public:<[decodedParentClass].deep_get[methods.public]>

    ## CASE: Has methods
    - if <[classScript].data_key[class.methods].exists>:
        - foreach <[classScript].data_key[class.methods].keys.exclude[constructor]> as:methodName:
            - if !<proc[GetMethodProtection_DC].context[<[class]>|<[methodName]>].is_truthy>:
                - foreach next

            - define objectMap.methods.<proc[GetMethodProtection_DC].context[<[class]>|<[methodName]>]>.list.<[methodName]>.class:<[class]>

    ## CASE: Has a constructor
    - if <[classScript].data_key[class.methods.constructor.script].exists>:
        - define constructor <[classScript].data_key[class.methods.constructor]>
        - define defs <[constructor].get[definitions].as[list].if_null[<list[]>]>
        - define defs <[defs].parse_tag[<[parse_value].replace[regex:\<&lb>.*\<&rb>]>]>
        - define globalAttrs <server.flag[dClasses.<[class]>.globalAttributes.list]>

        - run ClassScriptRunner def.method:constructor def.defMap:<[passedParams].include[<[globalAttrs]>]> def.object:<[objectMap]> def.isSelf:true save:constructorQueue

        - define constructorQueue <entry[constructorQueue].created_queue>
        - define constructorDefMap <[constructorQueue].definition_map>
        - define numOfDefs <[classScript].data_key[class.methods.constructor.script].parse_tag[<[parse_value].starts_with[define ].or[<[parse_value].starts_with[definemap ]>]>].count[true].add[<[defs].size>]>
        - define constructorDefStartIndex <[numOfDefs].sub[<[constructorDefMap].to_pair_lists.size>]>
        - define constructorDefStartIndex 1 if:<[constructorDefStartIndex].is[OR_LESS].than[0]>
        - define constructorDefPairList <[constructorDefMap].to_pair_lists.get[<[constructorDefStartIndex]>].to[last]>

        - foreach <[constructorDefPairList]>:
            - if <[value].get[1].starts_with[***]>:
                - define objectMap.attrs.protected.list.<[value].get[1]>:<[value].get[2]>

            - else if <[value].get[1].starts_with[**]>:
                - define objectMap.attrs.private.list.<[value].get[1]>:<[value].get[2]>

            - else if <[value].get[1].starts_with[*]>:
                - define objectMap.attrs.public.list.<[value].get[1]>:<[value].get[2]>

            - else if <[value].get[1].starts_with[^]>:
                - flag server dClasses.<[class]>.globalAttributes.list.<[value].get[1]>:<[value].get[2]>
                - define objectMap.classAttrs:->:<[value].get[1]>
                - define objectMap.classAttrs <[objectMap].get[classAttrs].deduplicate>

        - define objectMap.hash:<[objectMap].proc[GenerateUniqueClassHash]>

    - flag <[queue]> dClasses.<[object]>:<[objectMap].proc[EncodeClass]>


BuiltInMethods:
    type: data
    Methods:
        # Static and dynamic mean whether or not the user can change them.
        __str: dynamic
        __eq: dynamic
        __len: dynamic
        __hash: dynamic
        __delattr: static
        __class: static


Method:
    type: task
    debug: false
    definitions: call[`ElementTag(String)`]|queue[`?QueueTag`]|object[`?ElementTag(String)`]|method[`?ElementTag(String)`]
    description:
    - Will call the method with the provided name in the provided object.
    - All of this information is extracted from the `call` definition which must always be formatted as such;
    - `def.call:[Queue Object].[Object Name].[Method Name]`
    - Method will also take any number of arguments following `def.call` to satisfy any required definitions that the provided method may have.
    - Will return null if the action fails.
    - ---
    - → [Void]

    script:
    ## Will call the method with the provided name in the provided object.
    ## All of this information is extracted from the `call` definition which must always be
    ## formatted as such;
    ##
    ## def.call:[Queue Object].[Object Name].[Method Name]
    ##
    ## Method will also take any number of arguments following `def.call` to satisfy any required
    ## definitions that the provided method may have.
    ##
    ## Will return null if the action fails.
    ##
    ## call   : [ElementTag(String)] <------╮
    ## queue  : [QueueTag]           \      │--- Mutually Exclusive
    ## object : [ElementTag(String)]  | <---╯
    ## method : [ElementTag(String)] /
    ##
    ## >>> [Void]

    - define queue <[call].split[.].get[1].as[queue]> if:<[queue].exists.not>
    - define object <[call].split[.].get[2]> if:<[object].exists.not>
    - define method <[call].split[.].get[3]> if:<[method].exists.not>

    - if !<[queue].is_valid>:
        - run dClassesError def.queue:<queue> def.silent:false def.message:INVALID_QUEUE_ERROR
        - determine null

    - if !<[queue].has_flag[dClasses.<[object]>]>:
        - run dClassesError def.queue:<queue> def.silent:false def.message:INVALID_OBJECT_ERROR
        - determine null

    - define passedParams <queue.definition_map.exclude[call|queue|object|class]>
    - define decodedObject <[queue].flag[dClasses.<[object]>].proc[DecodeClass]>

    - if <[method].is_in[<script[BuiltInMethods].data_key[Methods].keys>]>:
        - if <[decodedObject].deep_get[methods.public.list.<[method]>].exists>:
            - if <script[BuiltInMethods].data_key[Methods.<[method]>]> == static:
                - run dClassesError def.queue:<queue> def.silent:false def.message:INVALID_CALL_ERROR
                - determine null

        - else:
            - run <[method]> def.queue:<[queue]> def.objectName:<[object]> def.decodedObject:<[decodedObject]> def.defMap:<[passedParams]> save:specialRes
            - determine <entry[specialRes].created_queue.determination.get[1]>

    - define class <[class].if_null[<[decodedObject].get[class]>]>
    - define classScript <script[<[class]>]>

    - if <proc[GetMethodProtection_DC].context[<[class]>|<[method]>].is_in[private|protected]>:
        - if <[queue].script.name> != classscriptrunner:
            - run dClassesError def.queue:<queue> def.silent:false def.message:INVALID_CALL_ERROR
            - determine null

        - define isSelf true

    - define allObjectAttributes <[decodedObject].deep_get[attrs.public.list]>
    - define allObjectAttributes <[allObjectAttributes].include[<[decodedObject].deep_get[attrs.protected.list]>]>
    - define allObjectAttributes <[allObjectAttributes].include[<[decodedObject].deep_get[attrs.private.list]>]>
    - define allObjectAttributes <[allObjectAttributes].include[<server.flag[dClasses.<[class]>.globalAttributes.list]>]>

    - if <[queue].script.name> == classscriptrunner:
        - run ClassScriptRunner def.defMap:<[allObjectAttributes].include[<[passedParams]>]> def.method:<[method]> def.object:<[decodedObject]> def.isSelf:<[isSelf].if_null[false]> def.queue:<[queue]> save:methodQueue

    - else:
        - run ClassScriptRunner def.defMap:<[allObjectAttributes].include[<[passedParams]>]> def.method:<[method]> def.object:<[decodedObject]> def.isSelf:<[isSelf].if_null[false]> save:methodQueue

    - define methodQueue <entry[methodQueue].created_queue>

    - foreach <[methodQueue].definition_map>:
        - if <[key].starts_with[***]>:
            - define objectMap.attrs.protected.list.<[key]>:<[value]>

        - else if <[key].starts_with[**]>:
            - define decodedObject.attrs.private.list.<[key]>:<[value]>

        - else if <[key].starts_with[*]>:
            - define decodedObject.attrs.public.list.<[key]>:<[value]>

        - else if <[key].starts_with[^]>:
            - flag server dClasses.<[class]>.globalAttributes.list.<[key]>:<[value]>
            - define decodedObject.classAttrs:->:<[key]>

    - define decodedObject.classAttrs:<[decodedObject].get[classAttrs].deduplicate> if:<[decodedObject].contains[classAttrs]>
    - flag <[queue]> dClasses.<[object]>:<[decodedObject].proc[EncodeClass]>

    - determine <[methodQueue].determination.get[1].if_null[null]>


GetAttribute:
    type: procedure
    debug: false
    definitions: call[`ElementTag(String)`]|queue[`?QueueTag`]|object[`?ElementTag(String)`]|attribute[`?ElementTag(String)`]
    description:
    - Returns the value of a public attribute in an object in a provided queue.
    - The format for `def.call` in `GetAttribute` will always be as follows;
    - def.call:[Queue Object].[Object Name].[Attribute Name]
    - Will return null if the action fails.
    - ---
    - → [ObjectTag]

    script:
    ## Returns the value of a public attribute in an object in a provided queue.
    ## The format for `def.call` in `GetAttribute` will always be as follows;
    ##
    ## def.call:[Queue Object].[Object Name].[Attribute Name]
    ##
    ## Will return null if the action fails.
    ##
    ## call      : [ElementTag(String)] <------╮
    ## queue     : [QueueTag]           \      │--- Mutually Exclusive
    ## object    : [ElementTag(String)]  | <---╯
    ## attribute : [ElementTag(String)] /
    ##
    ## >>> [ObjectTag]

    - define queue <[call].split[.].get[1].as[queue]> if:<[queue].exists.not>
    - define object <[call].split[.].get[2]> if:<[object].exists.not>
    - define attribute <[call].split[.].get[3]> if:<[attribute].exists.not>

    - if !<[queue].is_valid>:
        - run dClassesError def.queue:<queue> def.silent:false def.message:INVALID_QUEUE_ERROR
        - determine null

    - if !<[queue].has_flag[dClasses.<[object]>]>:
        - run dClassesError def.queue:<queue> def.silent:false def.message:INVALID_OBJECT_ERROR
        - determine null

    - define decodedObject <[queue].flag[dClasses.<[object]>].proc[DecodeClass]>

    - if <[queue].script.name> == classscriptrunner:
        - run dClassesError def.queue:<queue> def.silent:false def.message:<element[Do not use Get/SetAttribute tasks inside classes! You can simply access attributes like definitions.]>
        - determine null

    - if <[decodedObject]> == null:
        - determine null

    - if <[attribute].starts_with[***]>:
        - run dClassesError def.queue:<queue> def.silent:false def.message:<element[Cannot access a protected attribute from outside a class.]>
        - determine null

    - if <[attribute].starts_with[**]>:
        - run dClassesError def.queue:<queue> def.silent:false def.message:<element[Cannot access a private attribute from outside a class.]>
        - determine null

    - if <[attribute].starts_with[^]>:
        - if <[decodedObject].get[classAttrs].contains[<[attribute]>]>:
            - determine <server.flag[dClasses.<[decodedObject].get[class]>.globalAttributes.list.<[attribute]>]>

        - else:
            - run dClassesError def.queue:<queue> def.silent:false def.message:<element[This class does not have a global attribute with the name: <[attribute].color[red]>. You may only access the global attributes of the class that the current object was instantiated from.]>
            - determine null

    - if !<[attribute].starts_with[*]>:
        - define attribute *<[attribute]>

    - determine <[decodedObject].deep_get[attrs.public.list.<[attribute]>].if_null[null]>


SetAttribute:
    type: task
    debug: false
    definitions: call[`ElementTag(String)`]|value[`ObjectTag`]|queue[`?QueueTag`]|object[`?ElementTag(String)`]|attribute[`?ElementTag(String)`]
    description:
    - Will set the value of a public attribute in an objcet in a provided queue to the value provided in the `value` definition.
    - The format for `def.call` in `SetAttribute` will always be as follows;
    - `def.call:[Queue Object].[Object Name].[Attribute Name]`
    - Will return null if the action fails.
    - ---
    - → [Void]

    script:
    ## Will set the value of a public attribute in an objcet in a provided queue to the value
    ## provided in the `value` definition. The format for `def.call` in `SetAttribute` will always
    ## be as follows;
    ##
    ## def.call:[Queue Object].[Object Name].[Attribute Name]
    ##
    ## Will return null if the action fails.
    ##
    ## value     : [ObjectTag]
    ## call      : [ElementTag(String)] <------╮
    ## queue     : [QueueTag]           \      │--- Mutually Exclusive
    ## object    : [ElementTag(String)]  | <---╯
    ## attribute : [ElementTag(String)] /
    ##
    ## >>> [Void]

    - define queue <[call].split[.].get[1].as[queue]> if:<[queue].exists.not>
    - define object <[call].split[.].get[2]> if:<[object].exists.not>
    - define attribute <[call].split[.].get[3]> if:<[attribute].exists.not>

    - if !<[queue].is_valid>:
        - run dClassesError def.queue:<queue> def.silent:false def.message:INVALID_QUEUE_ERROR
        - determine null

    - if !<[queue].has_flag[dClasses.<[object]>]>:
        - run dClassesError def.queue:<queue> def.silent:false def.message:INVALID_OBJECT_ERROR
        - determine null

    - define decodedObject <[queue].flag[dClasses.<[object]>].proc[DecodeClass]>

    - if <[queue].script.name> == classscriptrunner:
        - run dClassesError def.queue:<queue> def.silent:false def.message:<element[Do not use Get/SetAttribute tasks inside classes! You can simply access attributes like definitions.]>
        - determine null

    - if <[decodedObject]> == null:
        - determine null

    - if <[attribute].starts_with[***]>:
        - run dClassesError def.queue:<queue> def.silent:false def.message:<element[Cannot access a protected attribute from outside a class.]>
        - determine null

    - if <[attribute].starts_with[**]>:
        - run dClassesError def.queue:<queue> def.silent:false def.message:<element[Cannot access a private attribute from outside a class.]>
        - determine null

    - if !<[attribute].starts_with[*]>:
        - define attribute *<[attribute]>

    - if !<[decodedObject].deep_get[attrs.public.list.<[attribute]>].exists>:
        - run dClassesError def.queue:<queue> def.silent:false def.message:<element[Cannot find attribute: <[attribute].color[red]> on object instantiated from class: <[decodedObject].get[class].color[aqua]>.]>
        - determine null

    - define decodedObject.attrs.public.list.<[attribute]>:<[value]>
    - flag <[queue]> dClasses.<[object]>:<[decodedObject].proc[EncodeClass]>


DestroyObject:
    type: task
    debug: false
    definitions: call[`ElementTag(String)`]|queue[`?QueueTag`]|object[`?ElementTag(String)`]
    description:
    - Will delete all references of the object provided in the `call` argument at the queue and server levels.
    - The format for `def.call` in `DestroyObject` will always be as follows;
    - `def.call:[Queue Object].[Object Name]`
    - Will return null if the action fails.
    - ---
    - → [Void]

    script:
    ## Will delete all references of the object provided in the `call` argument at the queue and
    ## server levels.
    ##
    ## The format for `def.call` in `DestroyObject` will always be as follows;
    ##
    ## def.call:[Queue Object].[Object Name]
    ##
    ## Will return null if the action fails.
    ##
    ## call      : [ElementTag(String)] <------╮
    ## queue     : [QueueTag]           \      │--- Mutually Exclusive
    ## object    : [ElementTag(String)] / <----╯
    ##
    ## >>> [Void]

    - define queue <[call].split[.].get[1].as[queue]> if:<[queue].exists.not>
    - define object <[call].split[.].get[2]> if:<[object].exists.not>

    - if !<[queue].is_valid>:
        - run dClassesError def.queue:<queue> def.silent:false def.message:INVALID_QUEUE_ERROR
        - determine null

    - if <[queue].has_flag[dClasses.<[object]>]>:
        - flag <[queue]> dClasses.<[object]>:!
