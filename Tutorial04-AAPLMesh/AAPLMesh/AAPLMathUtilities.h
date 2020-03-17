/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Header for vector, matrix, and quaternion math utility functions useful for 3D graphics
 rendering with Metal
*/

#import <simd/simd.h>

/// Since these are common methods, allow other libraries to overload the
//   implmentation of the methods here
#define AAPL_SIMD_OVERLOAD __attribute__((__overloadable__))

/// A single-precision quaternion type
typedef vector_float4 quaternion_float;

// Given a uint16_t encoded as a 16-bit float, returns a 32-bit float
float AAPL_SIMD_OVERLOAD float32_from_float16(uint16_t i);

// Given a 32-bit float, returns a uint16_t encoded as a 16-bit float
uint16_t AAPL_SIMD_OVERLOAD float16_from_float32(float f);

/// Returns the number of degrees in the specified number of radians
float AAPL_SIMD_OVERLOAD degrees_from_radians(float radians);

/// Returns the number of radians in the specified number of degrees
float AAPL_SIMD_OVERLOAD radians_from_degrees(float degrees);

/// Fast random seed
void AAPL_SIMD_OVERLOAD seedRand(uint32_t seed);

/// Fast integer random
int32_t AAPL_SIMD_OVERLOAD randi(void);

/// Fast floating-point random
float AAPL_SIMD_OVERLOAD randf(float x);

/// Returns a vector that is linearly interpolated between the two provided vectors
vector_float3 AAPL_SIMD_OVERLOAD vector_lerp(vector_float3 v0, vector_float3 v1, float t);

/// Returns a vector that is linearly interpolated between the two provided vectors
vector_float4 AAPL_SIMD_OVERLOAD vector_lerp(vector_float4 v0, vector_float4 v1, float t);

/// Converts a unit-norm quaternion into its corresponding rotation matrix
matrix_float3x3 AAPL_SIMD_OVERLOAD matrix3x3_from_quaternion(quaternion_float q);

/// Constructs a matrix_float3x3 from 9 float values
matrix_float3x3 AAPL_SIMD_OVERLOAD matrix_make(float m00, float m10, float m20,
                                               float m01, float m11, float m21,
                                               float m02, float m12, float m22);

/// Constructs a matrix_float4x4 from 16 float values
matrix_float4x4 AAPL_SIMD_OVERLOAD matrix_make(float m00, float m10, float m20, float m30,
                                               float m01, float m11, float m21, float m31,
                                               float m02, float m12, float m22, float m32,
                                               float m03, float m13, float m23, float m33);

/// Constructs a matrix_float3x3 from 3 vector_float3 values
matrix_float3x3 AAPL_SIMD_OVERLOAD matrix_make(vector_float3 col0,
                                               vector_float3 col1,
                                               vector_float3 col2);

/// Constructs a matrix_float4x4 from 4 vector_float4 values
matrix_float4x4 AAPL_SIMD_OVERLOAD matrix_make(vector_float4 col0,
                                               vector_float4 col1,
                                               vector_float4 col2,
                                               vector_float4 col3);

/// Constructs a rotation matrix from the provided angle and axis
matrix_float3x3 AAPL_SIMD_OVERLOAD matrix3x3_rotation(float radians, vector_float3 axis);

/// Constructs a rotation matrix from the provided angle and the axis (x, y, z)
matrix_float3x3 AAPL_SIMD_OVERLOAD matrix3x3_rotation(float radians, float x, float y, float z);

/// Constructs a scaling matrix with the specified scaling factors
matrix_float3x3 AAPL_SIMD_OVERLOAD matrix3x3_scale(float x, float y, float z);

/// Constructs a scaling matrix, using the provided vector as an array of scaling factors
matrix_float3x3 AAPL_SIMD_OVERLOAD matrix3x3_scale(vector_float3 s);

/// Extracts the upper-left 3x3 submatrix of the provided 4x4 matrix
matrix_float3x3 AAPL_SIMD_OVERLOAD matrix3x3_upper_left(matrix_float4x4 m);

/// Returns the inverse of the transpose of the provided matrix
matrix_float3x3 AAPL_SIMD_OVERLOAD matrix_inverse_transpose(matrix_float3x3 m);

/// Constructs a (homogeneous) rotation matrix from the provided angle and axis
matrix_float4x4 AAPL_SIMD_OVERLOAD matrix4x4_from_quaternion(quaternion_float q);

/// Constructs a rotation matrix from the provided angle and axis
matrix_float4x4 AAPL_SIMD_OVERLOAD matrix4x4_rotation(float radians, vector_float3 axis);

/// Constructs a rotation matrix from the provided angle and the axis (x, y, z)
matrix_float4x4 AAPL_SIMD_OVERLOAD matrix4x4_rotation(float radians, float x, float y, float z);

/// Constructs a scaling matrix with the specified scaling factors
matrix_float4x4 AAPL_SIMD_OVERLOAD matrix4x4_scale(float sx, float sy, float sz);

/// Constructs a scaling matrix, using the provided vector as an array of scaling factors
matrix_float4x4 AAPL_SIMD_OVERLOAD matrix4x4_scale(vector_float3 s);

/// Constructs a translation matrix that translates by the vector (tx, ty, tz)
matrix_float4x4 AAPL_SIMD_OVERLOAD matrix4x4_translation(float tx, float ty, float tz);

/// Constructs a translation matrix that translates by the vector (t.x, t.y, t.z)
matrix_float4x4 AAPL_SIMD_OVERLOAD matrix4x4_translation(vector_float3 t);

/// Constructs a view matrix that is positioned at (eyeX, eyeY, eyeZ) and looks toward
/// (centerX, centerY, centerZ), with the vector (upX, upY, upZ) pointing up for a left-handed coordinate system
matrix_float4x4 AAPL_SIMD_OVERLOAD matrix_look_at_left_hand(float eyeX, float eyeY, float eyeZ,
                                                              float centerX, float centerY, float centerZ,
                                                              float upX, float upY, float upZ);

/// Constructs a view matrix that is positioned at (eye) and looks toward
/// (target, with the vector (up) pointing up for a left-handed coordinate system
matrix_float4x4 AAPL_SIMD_OVERLOAD matrix_look_at_left_hand(vector_float3 eye,
                                                            vector_float3 target,
                                                            vector_float3 up);


/// Constructs a view matrix that is positioned at (eyeX, eyeY, eyeZ) and looks toward
/// (centerX, centerY, centerZ), with the vector (upX, upY, upZ) pointing up for a right-handed coordinate system
matrix_float4x4 AAPL_SIMD_OVERLOAD matrix_look_at_right_hand(float eyeX, float eyeY, float eyeZ,
                                                             float centerX, float centerY, float centerZ,
                                                             float upX, float upY, float upZ);

/// Constructs a view matrix that is positioned at (eye) and looks toward
/// (target, with the vector (up) pointing up for a right-handed coordinate system
matrix_float4x4 AAPL_SIMD_OVERLOAD matrix_look_at_right_hand(vector_float3 eye,
                                                             vector_float3 target,
                                                             vector_float3 up);

/// Constructs a symmetric orthographic projection matrix that maps (left, top) to (-1, 1),
/// (right, bottom) to (1, -1), and (nearZ, farZ) to (0, 1)
matrix_float4x4 AAPL_SIMD_OVERLOAD matrix_ortho(float left, float right, float bottom, float top, float nearZ, float farZ);

/// Constructs a symmetric perspective projection matrix for a right-handed coordinate system
/// with a vertical viewing angle of fovyRadians, the specified aspect ratio, and the provided near
/// and far Z distances
matrix_float4x4  AAPL_SIMD_OVERLOAD matrix_perspective_right_hand(float fovyRadians, float aspect, float nearZ, float farZ);

/// Constructs a symmetric perspective projection matrix for a left-handed coordinate system
/// with a vertical viewing angle of fovyRadians, the specified aspect ratio, and the provided near
/// and far Z distances
matrix_float4x4 AAPL_SIMD_OVERLOAD matrix_perspective_left_hand(float fovyRadians, float aspect, float nearZ, float farZ);

/// Returns the inverse of the transpose of the provided matrix
matrix_float4x4 AAPL_SIMD_OVERLOAD matrix_inverse_transpose(matrix_float4x4 m);

/// Constructs an identity quaternion
quaternion_float AAPL_SIMD_OVERLOAD quaternion_identity(void);

/// Constructs a quaternion of the form w + xi + yj + zk
quaternion_float AAPL_SIMD_OVERLOAD quaternion(float x, float y, float z, float w);

/// Constructs a quaternion of the form w + v.x*i + v.y*j + v.z*k
quaternion_float AAPL_SIMD_OVERLOAD quaternion(vector_float3 v, float w);

/// Constructs a unit-norm quaternion that represents rotation by the specified angle about the axis (x, y, z)
quaternion_float AAPL_SIMD_OVERLOAD quaternion(float radians, float x, float y, float z);

/// Constructs a unit-norm quaternion that represents rotation by the specified angle about the specified axis
quaternion_float AAPL_SIMD_OVERLOAD quaternion(float radians, vector_float3 axis);

/// Constructs a unit-norm quaternion from the provided matrix.
/// The result is undefined if the matrix does not represent a pure rotation.
quaternion_float AAPL_SIMD_OVERLOAD quaternion(matrix_float3x3 m);

/// Constructs a unit-norm quaternion from the provided matrix.
/// The result is undefined if the matrix does not represent a pure rotation.
quaternion_float AAPL_SIMD_OVERLOAD quaternion(matrix_float4x4 m);

/// Returns the length of the specified quaternion
float AAPL_SIMD_OVERLOAD quaternion_length(quaternion_float q);

float AAPL_SIMD_OVERLOAD quaternion_length_squared(quaternion_float q);

/// Returns the rotation axis of the specified unit-norm quaternion
vector_float3 AAPL_SIMD_OVERLOAD quaternion_axis(quaternion_float q);

/// Returns the rotation angle of the specified unit-norm quaternion
float AAPL_SIMD_OVERLOAD quaternion_angle(quaternion_float q);

/// Returns a quaternion from rotation axis and angle specified in radians
quaternion_float AAPL_SIMD_OVERLOAD quaternion_from_axis_angle(vector_float3 axis, float radians);

/// Returns a quaternion from a 3 x 3 rotation matrix
quaternion_float AAPL_SIMD_OVERLOAD quaternion_from_matrix3x3(matrix_float3x3 m);

/// Returns a quaternion from a euler angle specified in radians
quaternion_float AAPL_SIMD_OVERLOAD quaternion_from_euler(vector_float3 euler);

/// Returns a unit-norm quaternion
quaternion_float AAPL_SIMD_OVERLOAD quaternion_normalize(quaternion_float q);

/// Returns the inverse quaternion of the provided quaternion
quaternion_float AAPL_SIMD_OVERLOAD quaternion_inverse(quaternion_float q);

/// Returns the conjugate quaternion of the provided quaternion
quaternion_float AAPL_SIMD_OVERLOAD quaternion_conjugate(quaternion_float q);

/// Returns the product of two quaternions
quaternion_float AAPL_SIMD_OVERLOAD quaternion_multiply(quaternion_float q0, quaternion_float q1);

/// Returns the quaternion that results from spherically interpolating between the two provided quaternions
quaternion_float AAPL_SIMD_OVERLOAD quaternion_slerp(quaternion_float q0, quaternion_float q1, float t);

/// Returns the vector that results from rotating the provided vector by the provided unit-norm quaternion
vector_float3 AAPL_SIMD_OVERLOAD quaternion_rotate_vector(quaternion_float q, vector_float3 v);

/// Returns quaternion for the given forward and up vectors for right handed coordinate systems
quaternion_float AAPL_SIMD_OVERLOAD quaternion_from_direction_vectors_right_hand(vector_float3 forward, vector_float3 up);

/// Returns quaternion for the given forward and up vectors for left handed coordinate systems
quaternion_float AAPL_SIMD_OVERLOAD quaternion_from_direction_vectors_left_hand(vector_float3 forward, vector_float3 up);

/// Returns a vector in the +Z direction for the given quaternion
vector_float3 AAPL_SIMD_OVERLOAD forward_direction_vector_from_quaternion(quaternion_float q);

/// Returns a vector in the +Y direction for the given quaternion (for a left handed coordinate system,
///   negate for a right-handed system)
vector_float3 AAPL_SIMD_OVERLOAD up_direction_vector_from_quaternion(quaternion_float q);

/// Returns a vector in the +x direction for the given quaternion (for a left handed coordinate system)
///   negate for a right-handed system)
vector_float3 AAPL_SIMD_OVERLOAD right_direction_vector_from_quaternion(quaternion_float q);

