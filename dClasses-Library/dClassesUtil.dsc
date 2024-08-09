EncodeClass:
    type: procedure
    debug: false
    definitions: classObj[MapTag]
    script:
    - if <[classObj].object_type> != Map:
        - run dClassesError def.queue:<queue> def.silent:true def.message:<element[Cannot encode. Class object is not in valid format.]>
        - determine null

    - else if <[classObj].object_type> == Binary:
        - determine <[classObj]>

    - determine <[classObj].to_yaml.utf8_encode.gzip_compress>


DecodeClass:
    type: procedure
    debug: false
    definitions: classBinary[BinaryTag]
    script:
    - if <[classBinary].object_type> != Binary:
        - run dClassesError def.queue:<queue> def.silent:true def.message:<element[Cannot decode class object. Parameter provided is not a binary.]>
        - determine null

    - else if <[classBinary].object_type> == Map:
        - determine <[classBinary]>

    - determine <[classBinary].gzip_decompress.utf8_decode.parse_yaml>


GenerateUniqueClassHash:
    type: procedure
    debug: false
    definitions: classObj[MapTag]
    script:
    - if <[classObj].object_type> != Map:
        - run dClassesError def.queue:<queue> def.silent:true def.message:<element[Cannot generate hash. Class object is not in valid format.]>
        - determine null

    - determine <[classObj].include[randomizer=<util.current_time_millis><util.random.int[0].to[9]>].to_yaml.utf8_encode.gzip_compress.hash[SHA-256]>


ObjectRef:
    type: procedure
    debug: false
    definitions: queue[QueueTag]|object[ElementTag(String)]
    script:
    - determine <[queue].flag[dClasses.<[object]>]>


ClassScriptRunner:
    type: task
    debug: false
    definitions: defMap[MapTag]|method[ElementTag(String)]|object[Union[MapTag/BinaryTag]]|isSelf[?ElementTag(Boolean) = false]
    script:
    - foreach <[defMap]>:
        - define <[key]> <[value]>

    - define defMap:!

    - if <[isSelf]>:
        - define object <[object].proc[DecodeClass]> if:<[object].object_type.equals[Binary]>
        - flag <queue> dClasses.**self:<[object].proc[EncodeClass]>

    - if <[queue].exists>:
        - foreach <[queue].definition_map>:
            - if <[key].starts_with[*]> || <[key].starts_with[^]>:
                - define <[key]> <[value]>

        - define queue:!

    - flag server datahold.dClasses.<queue.id>.object:<[object]>
    - flag server datahold.dClasses.<queue.id>.method:<[method]>
    - define object:!
    - define method:!
    - define isSelf:!

    - if <server.flag[datahold.dClasses.<queue.id>.method]> == constructor:
        - inject <server.flag[datahold.dClasses.<queue.id>.object].get[class]> path:class.methods.constructor.script

    - else:
        # Unholy abomination, I know. Just try not to look at it for too long.
        - inject <server.flag[datahold.dClasses.<queue.id>.object].deep_get[methods.<proc[GetMethodProtection_DC].context[null|<server.flag[datahold.dClasses.<queue.id>.method]>|<server.flag[datahold.dClasses.<queue.id>.object]>]>.list.<server.flag[datahold.dClasses.<queue.id>.method]>.class]> path:class.methods.<server.flag[datahold.dClasses.<queue.id>.method]>.script

    - flag server datahold.dClasses.<queue.id>:!
