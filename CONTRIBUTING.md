# Contributing to Maze Solver - iOS

## Code Changes
'master' and 'release-x.x.x' branches are protected. Create your branch from the current 'release-x.x.x' branch and submit your pull request to merge into the release branch.  When it's time to publish the current release, the release branch will be merged into 'master' and 'master' will be tagged with the release #.

## Adding Mazes
Mazes must be fully bound by black lines. The start point should be marked red and the end point should be marked blue.
Refer to current mazes for examples.
### mazes.json
Add your maze metadata to the 'list' in the file.
You must adhere to the following format:
```
{
    "contributor": "<github_username>",
    "description": "<description>",
    "shape": "<Circular|Rectangular|Triangular|Hexagonal",
    "url": "https://ojeelabs.nyc3.digitaloceanspaces.com/<image_name>"
}
```
Add your image to the mazes/ directory.  Your image will be deleted once the pul request is complete and the maze is added to the ser
