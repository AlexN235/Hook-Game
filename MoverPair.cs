using Godot;
using System;


public partial class MoverPair : Node2D
{
	Object player, entrance, exit;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		player = GetNode<PlayerChar>("../PlayerChar");
		entrance = GetNode<MapMover>("MapMover");
		exit = GetNode<MapMoverExist>("MapMoverExit");
		var node = exit.Connect("hit_detected",Callable(self,"_teleport_player"));
		Console.WriteLine("its created");
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		
	}
	
	public void set_entrance_position(Vector2 pos) {
		
	}
	
	public void set_exit_position(Vector2 pos) {
		
	}
	
	public void teleport_player() {
		Console.WriteLine("hitting node#");
		player.SetGlobalPosition(exit.GlobalPosition);
	}
}
