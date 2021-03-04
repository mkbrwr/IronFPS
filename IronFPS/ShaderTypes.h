/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header containing types and enum constants shared between Metal shaders and C/ObjC source
But now this types are not shared, and instead Swift types with same memory layout are used.
*/

#ifndef AAPLShaderTypes_h
#define AAPLShaderTypes_h

#include <simd/simd.h>

typedef struct
{
    vector_float2 position;
    vector_float2 textureCoordinate;
} Vertex;

#endif /* AAPLShaderTypes_h */
