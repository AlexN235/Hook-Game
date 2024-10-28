using Godot;
using System;

enum PlayerState {Normal, Charge, Rocket}

public partial class PlayerChar : CharacterBody2D
{
	public const float Speed = 300.0f;
	public const float JumpVelocity = -400.0f;
	Node hookNode;
	public static Node map;
	
	// Player attributes
	PlayerState player_state;
	PlayerState prev_state;
	int charging_counter;
	int max_charging_counter;
	int charge_level;
	int max_charge_level;
	int rocket_counter;
	
	PackedScene _hook = (PackedScene)GD.Load("res://Hook.tscn");
	private TestMap _TestMap;

	// Get the gravity from the project settings to be synced with RigidBody nodes.
	public float gravity = ProjectSettings.GetSetting("physics/2d/default_gravity").AsSingle();

	public PlayerChar() {
		player_state = PlayerState.Normal;
		charging_counter = 0;
		max_charging_counter = 120;
		charge_level = 0;
		max_charge_level = 4;
		rocket_counter = 0;
	}
	
	public override void _Ready() {
		_TestMap = GetNode<TestMap>("TestMap");
		map = this.GetParent();
	}
	
	public override void _PhysicsProcess(double delta)
	{
		Vector2 velocity = Velocity;
		
		GD.Print(charging_counter);
		prev_state = player_state;
		switch (player_state)
		{
			case PlayerState.Normal:
				// Add the gravity.
				if (!IsOnFloor())
					velocity.Y += gravity * (float)delta;

				// Handle Jump.
				if (Input.IsActionJustPressed("jump") && IsOnFloor())
					velocity.Y = JumpVelocity;

				// Get the input direction and handle the movement/deceleration.
				// As good practice, you should replace UI actions with custom gameplay actions.
				Vector2 direction = Input.GetVector("move_left", "move_right", "move_up", "move_down");
				if (direction != Vector2.Zero && !IsOnFloor()) 
				{
					if (velocity.X * direction.X < 0)
					{
						velocity.X = -velocity.X;
					}
				}
				else if (direction != Vector2.Zero)
				{
					velocity.X = direction.X * Speed;
				}
				else if (direction == Vector2.Zero && !IsOnFloor()) 
				{
					// Slow down in the air if holding nothing.
					float newX = velocity.X;
					if (newX < 5 && newX > -5)
					{
						newX = 0;
					}
					else if (newX > 0)
					{ 
						newX -= 5;
					}
					else
					{
						newX += 5;
					}
					velocity.X = Mathf.MoveToward(Velocity.X, newX, Speed);
				}
				else
				{
					velocity.X = Mathf.MoveToward(Velocity.X, 0, Speed);
				}
				break;
			case PlayerState.Charge:
				// Charge missile jump
				if(charging_counter < max_charging_counter)
					charging_counter++;
				break;
			case PlayerState.Rocket:
				if (rocket_counter == 0)
					player_state = PlayerState.Normal;
				else if (rocket_counter == 1) 
				{
					rocket_counter--;
					velocity.Y = Mathf.MoveToward(velocity.Y, 0, Speed);
				}
				else if (rocket_counter > 1)
				{
					rocket_counter--;
					velocity.Y = -2 * Speed;
				}
				break;
		}
		
		// Handle hook
		if (Input.IsActionJustPressed("hook")) 
		{
			Vector2 playerPos, mousePos;
			playerPos = GlobalPosition;
			mousePos = GetViewport().GetMousePosition();
			((TestMap)map).createHook(playerPos, mousePos);
		}
		
		// Handle Charge
		if (player_state == PlayerState.Rocket) // Rocket has priority over lower states.
		{
			player_state = PlayerState.Rocket;
		}
		else if (Input.IsActionPressed("move_down") && IsOnFloor())
		{
			player_state = PlayerState.Charge;
			velocity.Y = Mathf.MoveToward(velocity.Y, 0, Speed);
			velocity.X = Mathf.MoveToward(velocity.X, 0, Speed);
		}
		else
		{
			player_state = PlayerState.Normal;
		}
		
		// Handle State Change.
		if (player_state == PlayerState.Normal && prev_state == PlayerState.Charge)
		 {
			player_state = PlayerState.Rocket;
			rocket_counter = 2 * (charging_counter / 10);
			charging_counter = 0;
		}
		Velocity = velocity;
		MoveAndSlide();
		
	}
	
	private static class HelperFunctions {
		
	}
	
}
