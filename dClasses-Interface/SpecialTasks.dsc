IsInstance:
    type: procedure
    debug: false
    definitions: call[ElementTag(String)]|class[ElementTag(String)]|queue[?QueueTag]|object[?Union[dClassObject / ElementTag(String)]]
    description:
    - Will return true if the dClasses object found at the location provided in the `call` definition is an instance of the class with the provided name.
    - The format for `def.call` in `IsInstance` will always be as follows;
    - `<proc[IsInstance].context[<element[[Queue Object].[Object Name]]>|[Class Name]]>`
    - Will return null if the action fails.
    - ---
    - → ?[ElementTag(Boolean)]

    script:
    ## Will return true if the dClasses object found at the location provided in the `call`
    ## definition is an instance of the class with the provided name.
    ##
    ## The format for `def.call` in `IsInstance` will always be as follows;
    ##
    ## <proc[IsInstance].context[<element[[Queue Object].[Object Name]]>|[Class Name]]>
    ##
    ## Will return null if the action fails.
    ##
    ## class  : [ElementTag(String)]
    ## call   : [ElementTag(String)] <------|
    ## queue  : [QueueTag]           \      |--- Mutually Exclusive
    ## object : [ElementTag(String)] / <----|
    ##
    ## >>> ?[ElementTag(Boolean)]

    - define queue <[call].split[.].get[1].as[queue]> if:<[queue].exists.not>
    - define object <[call].split[.].get[2]> if:<[object].exists.not>

    - if !<[queue].exists>:
        - if !<[object].object_type.is_in[Binary|Map]>:
            - determine null

        - define decodedObject <[object].proc[DecodeClass]>

    - else:
        - if <[object].object_type.is_in[Binary|Map]>:
            - define decodedObject <[object].proc[DecodeClass]>

        - else:
            - define decodedObject <[queue].flag[dClasses.<[object]>].proc[DecodeClass]>

    - determine <[decodedObject].get[class].equals[<[class]>]>


IsClass:
    type: procedure
    debug: false
    definitions: object[Union[BinaryTag / MapTag]]
    script:
    - if <[object].object_type> == Map:
        - define decodedObject <[object]>

    - else if <[object].object_type> == Binary:
        - define decodedObject <[object].proc[DecodeClass]>

    - else:
        - determine null

    - determine <[decodedObject].get[class].exists>


GetObjectRef:
    type: procedure
    debug: false
    definitions: 1[ElementTag(String)]|2[?QueueTag]
    script:
    - if !<[2].exists>:
        - define queue <[1].split[.].get[1].as[queue]>
        - define object <[1].split[.].get[2]>

    - else:
        - define queue <[1]>
        - define object <[2]>

    - if !<[queue].is_valid>:
        - determine null

    - if !<[queue].has_flag[dClasses.<[object]>]>:
        - determine null

    - determine <[queue].flag[dClasses.<[object]>]>


MakeObjectRef:
    type: task
    debug: false
    definitions: queue[QueueTag]|objectName[ElementTag(String)]|object[Union[BinaryTag / MapTag]]
    script:
    - if !<[queue].is_valid>:
        - stop

    - if <[object].object_type> == Map:
        - define decodedObject <[object]>

    - else if <[object].object_type> == Binary:
        - define decodedObject <[object].proc[DecodeClass]>

    - else:
        - stop

    - flag <[queue]> dClasses.<[objectName]>:<[decodedObject].proc[EncodeClass]>
