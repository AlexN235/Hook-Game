using Godot;
using System;

public partial class TestMap : Node
{
	PackedScene _hook = (PackedScene)GD.Load("res://Hook.tscn");
	Node hookNode;
	
	public static Node playerNode;
	public static int randomVar = 5;
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		playerNode = GetNode("PlayerChar");	
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		
	}
	
	public void createHook(Vector2 playerPos, Vector2 mousePos) {
		GD.Print("hello from map");
		hookNode = _hook.Instantiate();
		AddChild(hookNode);
	}
}
