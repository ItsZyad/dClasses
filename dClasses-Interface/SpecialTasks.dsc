IsInstance:
    type: procedure
    definitions: call[ElementTag(String)]|class[ElementTag(String)]|queue[?QueueTag]|object[?Union[dClassObject / ElementTag(String)]]
    script:
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
    definitions: call[ElementTag(String)]|queue[?QueueTag]|object[?ElementTag(String)]
    script:
    - define queue <[call].split[.].get[1].as[queue]> if:<[queue].exists.not>
    - define object <[call].split[.].get[2]> if:<[object].exists.not>

    - if !<[queue].is_valid>:
        - determine null

    - if !<[queue].has_flag[dClasses.<[object]>]>:
        - determine null

    - determine <[queue].flag[dClasses.<[object]>]>


MakeObjectRef:
    type: task
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
