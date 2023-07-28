extends Area2D

var cards

func on_collision(ev):
	if ev.is_in_group("player"):
		cards = get_tree().get_nodes_in_group("collectable")
		print("making " + str(cards.size()) + " cards float to player")
		for card in cards:
			# TODO: maybe make this function send the player who collided, and make it target them instead of closest?
			card.float_to_player()
