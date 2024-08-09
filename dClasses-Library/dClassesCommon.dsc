GlobalData_DC:
    type: data
    dClassesData:
        attributePrefixes:
            list: <list[^|***|**|*]>
            meaning:
                1: global
                2: protected
                3: private
                4: public

        methodPrefixes:
            list: <list[~**|~*]>
            meaning:
                1: protected
                2: private


IsValidObject_DC:
    type: procedure
    debug: false
    definitions: object[Union[BinaryTag/MapTag]]
    script:
    - if !<[object].exists>:
        - run dClassesError def.message:<element[[dClasses] : Failed to provide sufficient argument: (object)]> def.queue:<queue>
        - determine false

    - if <[object].object_type> == Binary:
        - define decodedObject <[object].proc[DecodeClass]>

        - if <[decodedObject].contains[class|public|private]>:
            - define rootClass <[decodedObject].get[class]>

            - if <server.has_flag[dClasses.<[rootClass]>]>:
                - determine true

        - determine false

    - else if <[object].object_type> == Map:
        - if <[object].contains[class|public|private]>:
            - define rootClass <[object].get[class]>

            - if <server.has_flag[dClasses.<[rootClass]>]>:
                - determine true

        - determine false

    - else:
        - determine false


IsSubClass_DC:
    type: procedure
    debug: false
    definitions: class[ElementTag(String)]
    script:
    - if !<[class].exists> :
        - run dClassesError def.message:<element[Failed to provide argument: (class)]> def.queue:<queue>
        - determine null

    - if !<script[<[class]>].exists> || !<script[<[class]>].data_key[class].exists>:
        - run dClassesError def.message:<element[Provided parameter <[class].color[gray]> is not a valid dClasses class!]> def.queue:<queue>
        - determine null

    - define classScript <script[<[class]>]>

    - determine <[classScript].data_key[class.extends]>


HasWhichPrefix_DC:
    type: procedure
    debug: false
    definitions: name[ElementTag(String)]|type[?ElementTag(String) = attribute]
    script:
    - define type <[type].if_null[attribute]>
    - define prefixes <script[GlobalData_DC].data_key[dClassesData.<[type]>Prefixes.list].parsed>

    - foreach <[prefixes]> as:prefix:
        - if <[name].starts_with[<[prefix]>]>:
            - determine <[prefix]>

    - determine null


GetPrefixMeaning_DC:
    type: procedure
    debug: false
    definitions: prefix[ElementTag(String)]|type[?ElementTag(String) = attribute]
    script:
    - define type <[type].if_null[attribute]>
    - define prefixIndex <script[GlobalData_DC].data_key[dClassesData.<[type]>Prefixes.list].parsed.find[<[prefix]>]>

    - if <[prefixIndex]> == -1:
        - determine null

    - determine <script[GlobalData_DC].data_key[dClassesData.<[type]>Prefixes.meaning.<[prefixIndex]>]>


#@@ REQUIRES TESTING
RemoveAttributePrefixes_DC:
    type: procedure
    debug: false
    definitions: attribute[ElementTag(String)]
    script:
    - define prefixes <script[GlobalData_DC].data_key[dClassesData.attributePrefixes.list].parsed>

    - foreach <[prefixes]> as:prefix:
        - if <[attribute].starts_with[<[prefix]>]>:
            - determine <[attribute].split[].get[<[prefix].length>].to[last]>

    - determine <[attribute]>

    # - if <[attribute].starts_with[~]> || <[attribute].starts_with[^]>:
    #     - determine <[attribute].split[].remove[1].unseparated>

    # - if <[attribute].starts_with[~*]>:
    #     - determine <[attribute].split[].remove[1|2].unseparated>

    # - if <[attribute].starts_with[]>


GetAttributeProtection_DC:
    type: procedure
    debug: false
    definitions: object[Union[BinaryTag/MapTag]]|attribute[ElementTag(String)]
    script:
    - if !(<[object].exists> && <[attribute].exists>):
        - run dClassesError def.message:<element[Failed to provide sufficient arguments: (object) & (attribute)]> def.queue:<queue>
        - determine null

    - if !<[object].proc[IsValidObject_DC]>:
        - run dClassesError def.message:<element[Provided parameter <[object].color[gray]> is not a valid dClasses object!]> def.queue:<queue>
        - determine null

    - if <[object].object_type> == Binary:
        - define object <[object].proc[DecodeClass]>

    - define prefix <[attribute].proc[HasWhichPrefix_DC]>

    - if <[prefix].is_truthy>:
        - determine <script[GlobalData_DC].data_key[dClassesData.attributePrefixes.meaning.<script[GlobalData_DC].data_key[dClassesData.attributePrefixes.list].parsed.find[<[prefix]>]>]>

    - else:
        - if <server.has_flag[dClasses.<[object].get[class]>.globalAttributes.list.^<[attribute]>]>:
            - determine global

        - foreach <script[GlobalData_DC].data_key[dClassesData.attributePrefixes.list].parsed> as:prefix:
            - foreach <script[GlobalData_DC].data_key[dClasses.attributePrefixes.meaning].values.exclude[global]> as:type:
                - if <[object].contains[attrs.<[type]>.list.<[prefix]><[attribute]>]>:
                    - determine <[type]>

        - determine null


GetMethodProtection_DC:
    type: procedure
    debug: false
    definitions: class[ElementTag(String)]|method[ElementTag(String)]|object[?Union[MapTag / BinaryTag]]
    script:
    - if !<[object].exists>:
        - if !(<[class].exists> && <[method].exists>):
            - run dClassesError def.message:<element[Failed to provide sufficient arguments: (class) & (method)]> def.queue:<queue>
            - determine null

        - if !<script[<[class]>].exists> || !<script[<[class]>].data_key[class].exists>:
            - run dClassesError def.message:<element[Provided parameter <[class].color[gray]> is not a valid dClasses class!]> def.queue:<queue>
            - determine null

        - define prefix <proc[HasWhichPrefix_DC].context[<[method]>|method]>

        - if <[prefix].is_truthy>:
            - determine <script[GlobalData_DC].data_key[dClassesData.methodPrefixes.meaning.<script[GlobalData_DC].data_key[dClassesData.methodPrefixes.list].parsed.find[<[prefix]>]>]>

        - define classScript <script[<[class]>]>

        - if <[classScript].data_key[class.methods.<[method]>].exists>:
            - determine public

        - foreach <script[GlobalData_DC].data_key[dClassesData.methodPrefixes.list].parsed> as:prefix:
            - foreach <script[GlobalData_DC].data_key[dClassesData.methodPrefixes.meaning].values.exclude[global]> as:type:
                - if <[classScript].data_key[class.methods.<[prefix]><[method]>].exists>:
                    - determine <[type]>

        - determine null

    - else:
        - if !<[method].exists>:
            - run dClassesError def.message:<element[Failed to provide sufficient arguments: (method)]> def.queue:<queue>
            - determine null

        - if <[object].object_type> == Binary:
            - define object <[object].proc[DecodeClass]>

        - foreach <script[GlobalData_DC].data_key[dClassesData.methodPrefixes.meaning].values.exclude[global].include[public]> as:type:
            - if <[object].deep_get[methods.<[type]>.list.<[method]>].exists>:
                - determine <[type]>

        - determine null
