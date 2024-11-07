using Godot;
using System;

namespace Helper 
{
	
}

public enum PlayerState {Normal, Charge, Rocket}

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
	
	float rocket_angle;

	private PackedScene _hook = (PackedScene)GD.Load("res://Hook.tscn");
	private TestMap _TestMap;
	
	

	// Get the gravity from the project settings to be synced with RigidBody nodes.
	public float gravity = ProjectSettings.GetSetting("physics/2d/default_gravity").AsSingle();

	public PlayerChar() 
	{
		player_state = PlayerState.Normal;
		charging_counter = 0;
		max_charging_counter = 120;
		charge_level = 0;
		max_charge_level = 4;
		rocket_counter = 0;
	}
	
	public override void _Ready() 
	{
		_TestMap = GetNode<TestMap>("TestMap");
		map = this.GetParent();
	}
	
	public override void _PhysicsProcess(double delta)
	{
		Vector2 velocity = Velocity;
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
				if (direction.X != 0 && !IsOnFloor()) 
				{
					if (velocity.X * direction.X < 0)
					{
						velocity.X = -velocity.X/2;
					}
				}
				else if (direction != Vector2.Zero && IsOnFloor())
				{
					velocity.X = direction.X * Speed;
				}
				else if (!IsOnFloor()) 
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
				velocity.Y = Mathf.MoveToward(velocity.Y, 0, Speed);
				velocity.X = Mathf.MoveToward(velocity.X, 0, Speed);
				break;
			case PlayerState.Rocket:
				Vector2 rocket_accel = new Vector2(3, 0).Rotated(rocket_angle);
				if (rocket_counter == 0)
					player_state = PlayerState.Normal;
				else if (rocket_counter == 1) 
				{
					rocket_counter--;
					velocity.Y = Mathf.MoveToward(velocity.Y, 0, Speed);
					velocity.X = Mathf.MoveToward(velocity.X, 0, Speed);
				}
				else if (rocket_counter > 1)
				{
					rocket_counter--;
					velocity = rocket_accel * Speed;
				}
				break;
		}
		
		// Handle State Changes.
		if (isInRocketState()) 
		{
			player_state = PlayerState.Rocket;
		}
		else if (checkChargeConditionMet())
		{
			playerIsChargingJump();
		}
		else if (checkRocketConditionMet())
		{
			changeToRocket();
		}
		else // default/normal state.
		{
			// change to normal state (doing nothing state) if no other state.
			player_state = PlayerState.Normal;
		}
		Velocity = velocity;
		MoveAndSlide();
	}
		
		/* ################################## ----------- ####################################
		################################## Helper Functions ################################## 
		##################################### ------------ ################################# */
		private bool checkChargeConditionMet() 
		{
			return Input.IsActionPressed("move_down") && IsOnFloor();
		}
		private bool isInRocketState()
		{
			return player_state == PlayerState.Rocket;
		}
		private bool checkRocketConditionMet()
		{
			return prev_state == PlayerState.Charge;
		}
		
		private void playerIsChargingJump()
		{
			player_state = PlayerState.Charge;
		}
		private void changeToRocket()
		{	// Transition of charging state to rocket state.
			player_state = PlayerState.Rocket;
			rocket_angle = this.GetNode<VisualPlayerArrow>("VisualPlayerArrow").getLaunchAngle();
			rocket_counter = 2 * (charging_counter / 10);
			charging_counter = 0;
		}
		
		public class StateHelper
		{
			// State Checkers
			public static bool isInRocketState(PlayerState state)
			{
				return state == PlayerState.Rocket;
			}
			public static bool isInChargeState(PlayerState state)
			{
				return state == PlayerState.Charge;
			}
			public static bool isInNormalState(PlayerState state)
			{
				return state == PlayerState.Normal;
			}
		}

}
