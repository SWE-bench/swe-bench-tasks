If we have multiple points defined at a same level , currently automated velocity would choose the point which comes first, but what I suggest is that we calculate all possible velocities of shortest path by and update _vel_dict by a dictionary

p._vel_dict[frame] = { point1 : calculated_velocity, point2 : calc_velocity}

point1 , point2 being two points with velocity defined with required frame at same level.

This could give user a choice to choose between any velocity he requires

If he updates p's velocity using set_vel(frame) then the dictionary is overridden by user defined velocity.
That's not what we'd want. The goal is to calculate the correct velocity or none at all.
> That's not what we'd want. The goal is to calculate the correct velocity or none at all.

Got it