dClassesError:
    type: task
    definitions: message[ElementTag(String)]|queue[QueueTag]|silent[ElementTag(Boolean)]
    script:
    - define silent true if:<[silent].is_boolean.not>
    - define queue <element[UNSPECIFIED].italicize> if:<[queue].exists.not>
    - define message <element[Internal error has occurred!]> if:<[message].exists.not>
    - define message <element[<[message]><n>Queue: <[queue].color[aqua]>]>
    - define prefix <element[[dClasses Error] : ].color[red]>

    - if !<[silent]>:
        - narrate <[prefix]><[message]>

    - debug ERROR <[prefix]><[message]>
    - determine <map[message=<[prefix]><[message]>;queue=<[queue]>]>


dClassesCallout:
    type: task
    definitions: message[ElementTag(String)]|queue[QueueTag]|silent[ElementTag(Boolean)]
    script:
    - define queue <element[UNSPECIFIED].italicize> if:<[queue].exists.not>

    - if !<[message].exists>:
        - run dClassesError def.message:<element[Cannot make callout with no message!]> def.queue:<[queue]>
        - determine null

    - define prefix <element[[dClasses Log] : ].color[aqua]>
    - define silent true if:<[silent].is_boolean.not>

    - if !<[silent]>:
        - narrate <[prefix]><[message]>

    - debug LOG <[prefix]><[message]>
    - determine <map[message=<[prefix]><[message]>;queue=<[queue]>]>
