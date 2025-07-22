# Get-DigitalOceanImage

Retrieves DigitalOcean images with filtering and pagination support.

## Syntax

```powershell
Get-DigitalOceanImage [[-Page] <int>] [[-Limit] <int>] [[-Type] <string>] [<CommonParameters>]

Get-DigitalOceanImage [-All] [[-Type] <string>] [<CommonParameters>]
```

## Description

The `Get-DigitalOceanImage` function retrieves information about available
DigitalOcean images, including distributions, applications, and custom images.
It supports filtering by image type and both paginated results and retrieving
all images at once.

## Parameters

### -Page

Specifies the page number for pagination (1-1000).

- **Type**: Int32
- **Default**: 1
- **Range**: 1-1000

### -Limit

Specifies the number of images per page (20-200).

- **Type**: Int32
- **Default**: 20
- **Range**: 20-200

### -Type

Filters images by type.

- **Type**: String
- **Valid Values**: "distribution", "application"
- **Default**: None (returns all types)

### -All

Retrieves all images by automatically handling pagination.

- **Type**: SwitchParameter
- **Default**: False

## Examples

### Example 1: Get images with default pagination

```powershell
Get-DigitalOceanImage
```

Returns the first 20 images of all types.

### Example 2: Get specific page with custom limit

```powershell
Get-DigitalOceanImage -Page 2 -Limit 50
```

Returns 50 images from page 2.

### Example 3: Get all distribution images

```powershell
$distributions = Get-DigitalOceanImage -All -Type "distribution"
```

Retrieves all available distribution images (Ubuntu, CentOS, etc.).

### Example 4: Get all application images

```powershell
$applications = Get-DigitalOceanImage -All -Type "application"
```

Retrieves all available application images (WordPress, Docker, etc.).

### Example 5: Working with image objects

```powershell
$images = Get-DigitalOceanImage -Type "distribution"
foreach ($image in $images) {
    Write-Host "Image: $($image.ToString())"
    Write-Host "Distribution: $($image.Distribution)"
    Write-Host "Public: $($image.Public)"
    Write-Host "Size: $($image.SizeGigabytes) GB"
    Write-Host "Created: $($image.CreatedAt)"
    Write-Host "Regions: $($image.Regions -join ', ')"
    Write-Host "---"
}
```

### Example 6: Find Ubuntu images

```powershell
$ubuntu = Get-DigitalOceanImage -All -Type "distribution" |
    Where-Object { $_.Name -like "*Ubuntu*" }

foreach ($img in $ubuntu) {
    Write-Host "$($img.Name) - $($img.Slug)"
}
```

### Example 7: Get image details using ToHashtable method

```powershell
$image = Get-DigitalOceanImage | Select-Object -First 1
$details = $image.ToHashtable()
$details | Format-Table -AutoSize
```

## Output

Returns `DigitalOceanImage` objects with the following properties:

- **Id**: Unique image identifier
- **Name**: Human-readable image name
- **Type**: Image type (distribution, application, backup, etc.)
- **Distribution**: Operating system distribution
- **Slug**: Short name identifier (e.g., 'ubuntu-20-04-x64')
- **Public**: Boolean indicating if image is publicly available
- **Regions**: Array of regions where image is available
- **CreatedAt**: Image creation timestamp
- **Status**: Image status (available, new, pending, etc.)
- **ErrorMessage**: Error message if image creation failed
- **SizeGigabytes**: Image size in gigabytes
- **MinDiskSize**: Minimum disk size required
- **Description**: Image description
- **Tags**: Hashtable of image tags

## Notes

- Requires valid `DIGITALOCEAN_TOKEN` environment variable
- Uses DigitalOcean API v2
- Image availability varies by region
- Supports verbose output for debugging
- Returns strongly-typed PowerShell class objects
- Custom images (snapshots) appear with type "backup"

## Related Links

- [Get-DigitalOceanAccount](Get-DigitalOceanAccount)
- [Get-DigitalOceanRegion](Get-DigitalOceanRegion)
- [DigitalOcean Images API](https://docs.digitalocean.com/reference/api/api-reference/#operation/list_all_images)
