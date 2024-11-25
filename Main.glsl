// Función para calcular la distancia a un cubo
float sdBox(vec3 p, vec3 b) {
    vec3 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}

// Función para calcular la distancia a un prisma octogonal
float sdOctogonPrism( in vec3 p, in float r, float h )
{
  const vec3 k = vec3(-0.9238795325,   // sqrt(2+sqrt(2))/2
                       0.3826834323,   // sqrt(2-sqrt(2))/2
                       0.4142135623 ); // sqrt(2)-1 
  // Reflejos
  p = abs(p);
  p.xy -= 2.0*min(dot(vec2( k.x,k.y),p.xy),0.0)*vec2( k.x,k.y);
  p.xy -= 2.0*min(dot(vec2(-k.x,k.y),p.xy),0.0)*vec2(-k.x,k.y);
  // Lados del polígono
  p.xy -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
  vec2 d = vec2( length(p.xy)*sign(p.y), p.z-h );
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

// Función para rotar un vector en 3D (eje arbitrario)
mat3 rotate3D(float angle, vec3 axis) {
    float c = cos(angle);
    float s = sin(angle);
    return mat3(c + axis.x * axis.x * (1.0 - c), axis.x * axis.y * (1.0 - c) - axis.z * s, axis.x * axis.z * (1.0 - c) + axis.y * s,
                axis.y * axis.x * (1.0 - c) + axis.z * s, c + axis.y * axis.y * (1.0 - c), axis.y * axis.z * (1.0 - c) - axis.x * s,
                axis.z * axis.x * (1.0 - c) - axis.y * s, axis.z * axis.y * (1.0 - c) + axis.x * s, c + axis.z * axis.z * (1.0 - c));
}

// Función principal para calcular la forma de la escena
float map(in vec3 pos) {
    // Velocidad angular de rotación de los cubos
    float omega = 2.0; // Radianes por segundo
    float angle = iTime * omega; // Ángulo de rotación según el tiempo

    // Posiciones de los cubos
    vec3 positions[4];
    positions[0] = vec3(1.0, 0.0, 1.0);
    positions[1] = vec3(1.0, 0.0, -1.0);
    positions[2] = vec3(-1.0, 0.0, 1.0);
    positions[3] = vec3(-1.0, 0.0, -1.0);

    // Tamaño de los cubos
    vec3 cubeSize = vec3(0.5);

    // Calculamos la distancia mínima a cada cubo
    float d = 1e3;
    for (int i = 0; i < 4; i++) {
        // Cada cubo rota independientemente sobre su propio eje
        vec3 rotatedPos = pos - positions[i];
        rotatedPos = rotate3D(angle, vec3(0.0, 0.0, 1.0)) * rotatedPos; // Rotación sobre el eje Z
        d = min(d, sdBox(rotatedPos, cubeSize)); // Distancia mínima a la caja
    }

    // Definir el tamaño y la posición del chasis (hexaedro)
    vec3 chasisSize = vec3(2.0, 0.2, 1.0); // Tamaño del hexaedro
    vec3 chasisPos = vec3(0.0, 0.9, 0.0);  // Posición del chasis

    // Calculamos la distancia mínima al hexaedro
    d = min(d, sdBox(pos - chasisPos, chasisSize));

    // Ahora calculamos la distancia mínima a un prisma octogonal
    d = min(d, sdOctogonPrism(pos - vec3(2.0, 0.0, 1.0), 0.5, 0.1)); // Ejemplo de un prisma octogonal

    return d;
}

// Función para calcular la normal de la escena
vec3 calcNormal(in vec3 pos) {
    vec2 e = vec2(1.0, -1.0) * 0.5773;
    const float eps = 0.0005;
    return normalize(e.xyy * map(pos + e.xyy * eps) +
                     e.yyx * map(pos + e.yyx * eps) +
                     e.yxy * map(pos + e.yxy * eps) +
                     e.xxx * map(pos + e.xxx * eps));
}

// Función principal para renderizar la imagen
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Configuración de la cámara
    vec3 ro = vec3(3.0, 2.0, 3.0); // Posición de la cámara
    vec3 ta = vec3(0.0, 0.0, 0.0); // Objetivo de la cámara

    vec3 ww = normalize(ta - ro);
    vec3 uu = normalize(cross(vec3(0.0, 1.0, 0.0), ww));
    vec3 vv = cross(ww, uu);

    vec2 p = (-iResolution.xy + 2.0 * fragCoord) / iResolution.y;
    vec3 rd = normalize(p.x * uu + p.y * vv + 1.5 * ww);

    // Raymarching
    float t = 0.0;
    const float tmax = 10.0;
    const float prec = 0.001;
    vec3 pos;

    for (int i = 0; i < 256; i++) {
        pos = ro + t * rd;
        float d = map(pos);
        if (d < prec || t > tmax) break;
        t += d;
    }

    // Shading
    vec3 col = vec3(0.0);
    if (t < tmax) {
        vec3 normal = calcNormal(pos);

        // Luz y sombra
        float light = clamp(dot(normal, normalize(vec3(0.5, 1.0, 0.75))), 0.0, 1.0);

        // Colorear el cubo y otros elementos
        col = vec3(0.8, 0.2, 0.2) * light;  // Color rojo para el cubo
    }

    fragColor = vec4(col, 1.0);
}
