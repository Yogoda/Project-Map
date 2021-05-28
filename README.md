# Project Map plugin for Godot

This adds a new tab "Project" to your editor.

Simply drag and drop files you need to access often into the graph.

Click on the nodes to access the scenes/scripts.

Drag the node icons to move the nodeds.

![Screenshot](screenshots/project_view.png)

### Group nodes

Provides a visual grouping.
Click on "Add Group" button, then click on graph to create a group node.

Drag file nodes to add them to the group.

Drag the icon to move the group and children.
Press ALT while dragging to only move the group node.

You can resize it with the lower right handle.

![Screenshot](screenshots/group_nodes.png)

### Comment nodes

Click on "Add Comment" button, then click on graph to create a comment node.

Use the handle to resize according to the text. The handle only appears when hovering the text.

# Changelog

## 1.3
  - Add directory node
  - Add comment node
  - Add undo/redo
  - Improve group node handling

## 1.2 
- Add group node
- Save file node data to improve loading time

## 1.1
- Update graph when moving or deleting files
- Save graph scene under a different name (project_map_save.tscn)
- Can now drag multiple files at once

## 1.0
- Initial release
