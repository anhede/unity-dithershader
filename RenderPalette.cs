using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RenderPalette : MonoBehaviour
{
    public PaletteScriptableObject palette;
    [Range(0,1)]
    public float noiseFactor;
    public Vector2 resolution;
    public bool renderTexture;
    private Vector2 lastResolution;
    private Material renderMat;


    // Start is called before the first frame update
    void Awake()
    {
        lastResolution = resolution;
        renderMat = new Material(Shader.Find("Hidden/RenderFilter/Palette"));
        ResetResolution();
    }


    // Update is called once per frame
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // Update render texture if desired size has changed
        if(resolution != lastResolution)
        {
            ResetResolution();
            lastResolution = resolution;
        }

        // Setting palette
        Texture2D paletteTexture = new Texture2D(8, 1, TextureFormat.RGBA32, false);

        // Draw filter
        for (int x = 0; x < 8; x++)
        {
            paletteTexture.SetPixel(x, 0, palette.colors[x]);
        }
        paletteTexture.Apply();
        renderMat.SetTexture("_Palette", paletteTexture);
        renderMat.SetFloat("_NoiseVal", noiseFactor);
        renderMat.SetVector("_ScreenRes", resolution);
        Graphics.Blit(source, destination, renderMat);
    }

    // Adjust filter resolution on the fly
    void ResetResolution()
    {
        if (renderTexture)
        {
            GetComponent<Camera>().targetTexture = 
                new RenderTexture((int)resolution.x, (int)resolution.y, 24);
        }
        if (GetComponent<Camera>().tag == "MainCamera")
        {
            Screen.SetResolution((int)resolution.x, (int)resolution.y, false);
        }
    }
}
