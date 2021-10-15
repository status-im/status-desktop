import json

include  ../../common/json_utils

type Dto* = ref object
    id*, name*, image*, collectibleType*, description*, externalUrl*: string