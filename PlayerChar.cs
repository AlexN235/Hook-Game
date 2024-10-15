using Godot;
using System;


public partial class PlayerChar : CharacterBody2D
{
	public const float Speed = 300.0f;
	public const float JumpVelocity = -400.0f;
	Node hookNode;
	public static Node map;
	
	PackedScene _hook = (PackedScene)GD.Load("res://Hook.tscn");
	private TestMap _TestMap;

	// Get the gravity from the project settings to be synced with RigidBody nodes.
	public float gravity = ProjectSettings.GetSetting("physics/2d/default_gravity").AsSingle();

	public PlayerChar() {
		
	}
	
	public override void _Ready() {
		_TestMap = GetNode<TestMap>("TestMap");
		map = this.GetParent();
	}
	
	public override void _PhysicsProcess(double delta)
	{
		Vector2 velocity = Velocity;
		
		
		// Add the gravity.
		if (!IsOnFloor())
			velocity.Y += gravity * (float)delta;

		// Handle Jump.
		if (Input.IsActionJustPressed("jump") && IsOnFloor())
			velocity.Y = JumpVelocity;

		// Get the input direction and handle the movement/deceleration.
		// As good practice, you should replace UI actions with custom gameplay actions.
		Vector2 direction = Input.GetVector("move_left", "move_right", "move_up", "move_down");
		if (direction != Vector2.Zero)
		{
			velocity.X = direction.X * Speed;
		}
		else
		{
			velocity.X = Mathf.MoveToward(Velocity.X, 0, Speed);
		}
		
		// Handle hook
		if(Input.IsActionJustPressed("hook")) {
			Vector2 playerPos, mousePos;
			playerPos = GlobalPosition;
			mousePos = GetViewport().GetMousePosition();
			((TestMap)map).createHook(playerPos, mousePos);
			}
			
		Velocity = velocity;
		MoveAndSlide();
	}
	
	private static class HelperFunctions {
		
	}
	
}