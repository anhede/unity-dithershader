using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Holder for palettes
/// </summary>
[CreateAssetMenu(fileName = "Palette", menuName = "ScriptableObjects/Palette", order = 1)]
public class PaletteScriptableObject : ScriptableObject
{
    public Color[] colors = new Color[8]; // 8 Color palette
}
