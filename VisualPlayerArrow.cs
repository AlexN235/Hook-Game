using Godot;
using System;

public partial class VisualPlayerArrow : Node2D
{
	
	int radius;
	float angle;
	Node2D player;
	
	
	public override void _Ready()
	{
		radius = 20;
		player = GetParent() as Node2D;
	}

	public override void _Process(double delta)
	{
		// Change angle.
		Vector2 mouse_pos = GetGlobalMousePosition();
		this.LookAt(mouse_pos);
		
		// Change position.
		angle = player.GlobalPosition.AngleToPoint(mouse_pos);
		this.Position = new Vector2(radius, 0).Rotated(angle);
	}
	
	public float getLaunchAngle()
	{
		return angle;
	}
}
