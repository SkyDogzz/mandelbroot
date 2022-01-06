#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    float x1 = -2.1;
    float x2 = 0.6;
    float y1 = -1.2;
    float y2 = 1.2;
    int cpt = 0;
    int cpt2 = 0;
    int cpt3 = 0;

    float c_r, c_i, z_r, z_i, tmp;
    int i;

    int zoom = 100;
    int iteration_max = 50;

    float image_x, image_y;

    image_x = (x2 - x1) * zoom;
    image_y = (y2 - y1) * zoom;

    printf("%f -- %f\n", image_x, image_y);

    for (int x = 0; x < image_x; x++)
    {
        for (int y = 0; y < image_y; y++)
        {
            cpt++;

            c_r = x / zoom + x1;
            c_i = y / zoom + y1;
            z_r = 0;
            z_i = 0;
            i = 0;

            do
            {
                tmp = z_r;
                z_r = z_r * z_r - z_i * z_i + c_r;
                z_i = 2 * z_i * tmp + c_i;
                i = i + 1;
                cpt3++;
            } while (z_r * z_r + z_i * z_i < 4 && i < iteration_max);
            if (i == iteration_max)
            {
                cpt2++;
            }
        }
    }

    printf("%d\n%d\n", cpt, cpt2);

    return EXIT_SUCCESS;
}