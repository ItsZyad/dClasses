__delattr:
    type: task
    definitions: queue[`QueueTag`]|objectName[`ElementTag(String)`]|defMap[`MapTag`]
    script:
    - if <[defMap].size> > 1:
        - define attribute <[defMap].exclude[raw_context].values.get[1]>

    - else if <[defMap].contains[raw_context]>:
        - define attribute <[defMap].get[raw_context].get[2]>

    - else:
        - run dClassesError def.queue:<queue> def.silent:false def.message:INSUFFICIENT_ARGUMENTS

    - flag <[queue]> dClasses.<[objectName]>.public.list.attribute:!


__eq:
    type: task
    definitions: queue[`QueueTag`]|decodedObject[`MapTag`]|defMap[`MapTag`]
    script:
    - if <[defMap].size> > 1:
        - define comparisonClass <[defMap].exclude[raw_context].values.get[1]>

    - else if <[defMap].contains[raw_context]>:
        - define comparisonClass <[defMap].get[raw_context].get[2]>

    - else:
        - run dClassesError def.queue:<queue> def.silent:false def.message:INSUFFICIENT_ARGUMENTS
        - determine null

    - choose <[comparisonClass].object_type>:
        - case Binary:
            - define comparisonClass <[comparisonClass].proc[DecodeClass]>

        - case Element:
            - define comparisonClass <[queue].flag[dClasses.<[comparisonClass]>].proc[DecodeClass]>

        - case Map:
            - define comparisonClass <[comparisonClass]>

        - default:
            - run dClassesError def.queue:<queue> def.silent:false def.message:INVALID_CLASS_PARAMETER
            - determine null

    - determine <[decodedObject].exclude[hash].equals[<[comparisonClass].exclude[hash]>]>


__str:
    type: task
    definitions: decodedObject[`MapTag`]
    script:
    - determine <element[dClasses object: ]><element[<[decodedObject].proc[EncodeClass].as[element].split[].get[1].to[17].unseparated>... ].color[aqua]><element[[Queue]].color[light_purple].on_hover[<[decodedObject].get[queue].id>]>


__len:
    type: task
    definitions: decodedObject[`MapTag`]
    script:
    - determine <[decodedObject].proc[EncodeClass].length>


__hash:
    type: task
    definitions: decodedObject[`MapTag`]
    script:
    - determine <[decodedObject].get[hash]>


__class:
    type: task
    definitions: decodedObject[`MapTag`]
    script:
    - determine <[decodedObject].get[class]>


# TODO: Add an __iter task
