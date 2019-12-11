#include "saturn_engine/_lib.h"
#include "helper/scene.h"
#include "scene/{{low}}.h"

static scene_{{low}}_data *data;

void scene_{{low}}_init(void)
{
    data = saten_scene_access_data(saten_scene_self());
}

void scene_{{low}}_update(bool c)
{
}

void scene_{{low}}_draw(void)
{
}

void scene_{{low}}_quit(void)
{
}
