global.selectedElement = noone;
global.mix = 1;
global.compression = 0;

function Palette(_x, _y, _sprite) constructor {
	static drawSize = 8;
	size = 256;
	sprite_index = _sprite;
	colors = array_create(0);
	selected = 0;
	
	// This is cursed so bear with me
	static generate_colors = function() {
		// Get width/height
		sprite_width = sprite_get_width(sprite_index);
		sprite_height = sprite_get_height(sprite_index);	
	
		// Create buffer - we will stuff our sprite in here after rendering it to a surface
		colorBuffer = buffer_create(sprite_width * sprite_height * 4, buffer_fixed, 1);
	
		#region SURFACE GARBAGE
		// Create surface, target, and clear
		var surf = surface_create(sprite_width, sprite_height);
		surface_set_target(surf);
		draw_clear_alpha(c_black, 0);
		
		// Draw sprite to surface and reset target
		draw_sprite(sprite_index, 0, 0, 0);
		surface_reset_target();
		
		// Stuff surface into buffer and free surface
		buffer_get_surface(colorBuffer, surf, 0);
		surface_free(surf);
	
		#endregion
		
		// Seek to start of buffer
		buffer_seek(colorBuffer, buffer_seek_start, 0);
		
		// Start at end of color array
		var i = array_length(colors);
		
		// Repeat buffer length in bytes divided by 4 because we'll be reading 4 at a time - RGBA
		repeat (buffer_get_size(colorBuffer) / 4) {
			
			// READS MUST BE DONE HERE - THEIR ORDER IS NOT GUARANTEED IN THE make_color_rgb() METHOD HEADER
			var r = buffer_read(colorBuffer, buffer_u8),
				g = buffer_read(colorBuffer, buffer_u8),
				b = buffer_read(colorBuffer, buffer_u8);
			
			// Construct color
			//var col = make_color_rgb(r, g, b);
			
			// If alpha is 0, skip the rest of the iteration
			if (buffer_read(colorBuffer, buffer_u8) == 0) continue;
			
			// Skip rest of iteration if color is found in existing palette
			var skip = false,
				collision = -1;
			for (var j = 0; j < array_length(colors); j++) {
				if (colors[j].r == r && colors[j].g == g) {
					if (colors[j].b == b) {
						skip = true;
						break;
					}
					if (collision == -1) collision = j;
				}
			}
			if (skip) continue;
			
			// Add as new Color to colors array, then increment
			colors[i] = new Color(r, g, b);
			if (collision != -1) {
				colors[i].collision = collision;
			}
			i++;
		}
		
		// Delete buffer
		buffer_delete(colorBuffer);
	}
	
	generate_colors();
	
	static draw = function(_x, _y) {
		// Loop through colors and draw square for each based on drawSize

		for (var i = 0; i < array_length(colors); i++) {
			draw_rectangle_color(_x, _y + (i * drawSize), _x + drawSize - 1, _y + drawSize - 1 + (i * drawSize), colors[i].rgb, colors[i].rgb, colors[i].rgb, colors[i].rgb, false);
			if (colors[i].collision != -1) {
				draw_line_color(_x + drawSize, _y + (i * drawSize) + drawSize / 2, _x + drawSize + 6, _y + (i * drawSize) + drawSize / 2, colors[colors[i].collision].rgb, c_orange);
				draw_line_color(_x + drawSize + 6, _y + (i * drawSize) + drawSize / 2, _x + drawSize + 6, _y + (colors[i].collision * drawSize) + drawSize / 2, c_orange, c_orange);
				draw_line_color(_x + drawSize, _y + (colors[i].collision * drawSize) + drawSize / 2, _x + drawSize + 6, _y + (colors[i].collision * drawSize) + drawSize / 2, colors[colors[i].collision].rgb, c_orange);
			}
		}
		
		draw_rectangle_color(_x, _y + (selected * drawSize), _x + drawSize - 1, _y + drawSize + (selected * drawSize) - 1, c_white, c_white, c_aqua, c_white, true);
		
		
		
		//draw_set_halign(fa_left);
		//draw_set_valign(fa_top);
		
		/*draw_text(_x + 32, _y + 1, "R:" + string(colors[selected].r) + "\nG:" + string(colors[selected].g) + "\nB:" + string(colors[selected].b));
		
		var _off = 23;
		var _r = make_color_rgb(colors[selected].r, 0, 0),
			_g = make_color_rgb(0, colors[selected].g, 0),
			_b = make_color_rgb(0, 0, colors[selected].b);
		
		draw_rectangle_color(_x + _off, _y, _x + _off + drawSize - 1, _y + drawSize - 1, _r, _r, _r, _r, false);
		draw_rectangle_color(_x + _off, _y + (drawSize), _x + _off + drawSize - 1, _y + drawSize - 1 + (drawSize), _g, _g, _g, _g, false);
		draw_rectangle_color(_x + _off, _y + (drawSize * 2), _x + _off + drawSize - 1, _y + drawSize - 1 + (drawSize * 2), _b, _b, _b, _b, false);
		*/
		
		/*
		var _hOff = 19;
		
		draw_rectangle_color(_x + _hOff, _y, _x + _hOff + 255, _y + drawSize - 1, c_grey, c_grey, c_grey, c_grey, true);
		draw_rectangle_color(_x + _hOff, _y, _x + _hOff + 255, _y + drawSize - 1, c_black, $0000ff, $0000ff, c_black, false);
		draw_line_color(_x + _hOff + colors[selected].r, _y - 1, _x + _hOff + colors[selected].r, _y + drawSize - 1, c_white, c_white);
		draw_text(_x + _hOff + 255 + 5, _y, string(colors[selected].r));
		
		draw_rectangle_color(_x + _hOff, _y + (drawSize + 1), _x + _hOff + 255, _y + drawSize - 1 + (drawSize + 1), c_grey, c_grey, c_grey, c_grey, true);
		draw_rectangle_color(_x + _hOff, _y + (drawSize + 1), _x + _hOff + 255, _y + drawSize - 1 + (drawSize + 1), c_black, $00ff00, $00ff00, c_black, false);
		draw_line_color(_x + _hOff + colors[selected].g, _y + (drawSize), _x + _hOff + colors[selected].g, _y + drawSize * 2, c_white, c_white);
		draw_text(_x + _hOff + 255 + 5, _y + drawSize + 1, string(colors[selected].g));
		
		
		draw_rectangle_color(_x + _hOff, _y + ((drawSize + 1) * 2), _x + _hOff + 255, _y + drawSize - 1 + ((drawSize + 1) * 2), c_grey, c_grey, c_grey, c_grey, true);
		draw_rectangle_color(_x + _hOff, _y + ((drawSize + 1) * 2), _x + _hOff + 255, _y + drawSize - 1 + ((drawSize + 1) * 2), c_black, $ff0000, $ff0000, c_black, false);
		draw_line_color(_x + _hOff + colors[selected].b, _y + 1 + (drawSize * 2), _x + _hOff + colors[selected].b, _y + 1 + drawSize * 3, c_white, c_white);
		draw_text(_x + _hOff + 255 + 5, _y + 2 + drawSize * 2, string(colors[selected].b));
		*/
	}
	
	// TODO: Render to surface.
	// Y I K E S.
	static render = function(_surface) {
		
	}
}

function TruePalette(_x, _y) : ScreenElement(_x, _y, 8, 8) constructor {
	x = _x;
	y = _y;
	ystart = y;
	depth = other.depth;
	
	sprites = array_create(0);
	colors = array_create(0);
	oldColors = array_create(0);
	surfSize = 256;
	renderSurface = surface_create(surfSize, surfSize);
	selected = 0;
	
	var rampDist = floor(w * 2.5);
	yOffset = 40;
	picker = color_picker_create(x + 18, y + yOffset, 176, 8, 2, c_black);
	hex = new TextBox(x + rampDist + 40, y - 7 + yOffset, "", 6);
	
	
	var i = 0;
	subElements[i++] = hex;
	
	static target_surface = function() {
		if (!surface_exists(renderSurface) || surface_get_width(renderSurface) != surfSize) renderSurface = surface_create(surfSize, surfSize);
		surface_set_target(renderSurface);
	}
	
	// TODO: surface here can be lost which screws up everything else! needs a a regen mechanism.
	add_colors_from_sprite = function(_index) {
		//ds_list_add(sprites, new AdvancedSprite(_index));
		var newSpr = new AdvancedSprite(_index);
		sprites[array_length(sprites)] = newSpr;

		var i = 0;
		repeat (array_length(newSpr.colors)) {
			var col = newSpr.colors[i],
				j = 0,
				len = array_length(colors),
				skip = false,
				collision = -1;
			
			repeat (len) {
				if (oldColors[j].r == col.r && oldColors[j].g == col.g) {
					if (oldColors[j].b == col.b) {
						skip = true;
						break;
					}
					if (collision == -1) collision = j;
				}	
				++j;
			}
			
			if (!skip) {
				col.collision = collision;
				colors[len] = col;
				oldColors[len] = new Color(col.r, col.g, col.b);
				h += 8;
				
				var col = colors[len],
				var old = oldColors[len];
				target_surface();
				var _x = floor(old.r * (surfSize / 256));
				var _y = floor(old.g * (surfSize / 256));
				draw_rectangle_color(_x, _y, _x, _y, col.rgb, col.rgb, col.rgb, col.rgb, false);
				surface_reset_target();
			}
			++i;
		}
		
		color_picker_set(picker, colors[selected].rgb);
		hex.text = dec_to_hex(colors[selected].r, 2) + dec_to_hex(colors[selected].g, 2) + dec_to_hex(colors[selected].b, 2);
	}
	
	rerender_surface = function() {
		var i = 0;
		target_surface();
		repeat (array_length(oldColors)) {
			var col = colors[i],
				old = oldColors[i];
				
			var _x = floor(old.r * (surfSize / 256));
			var _y = floor(old.g * (surfSize / 256));
			draw_rectangle_color(_x, _y, _x, _y, col.rgb, col.rgb, col.rgb, col.rgb, false);
			++i;
		}
		surface_reset_target();
	}
	
	on_update_click = function(_x, _y) {
		var tmp = colors[selected],
			tmpOld = oldColors[selected],
			tmpSel = selected;
		
		selected = clamp(floor(_y / w), 0, array_length(colors) - 1);
		
		// Swap color positions
		if (keyboard_check(vk_shift)) {
			colors[tmpSel] = colors[selected];
			colors[selected] = tmp;
			oldColors[tmpSel] = oldColors[selected];
			oldColors[selected] = tmpOld;
		}
		
		color_picker_set(picker, colors[selected].rgb);
		hex.text = dec_to_hex(colors[selected].r, 2) + dec_to_hex(colors[selected].g, 2) + dec_to_hex(colors[selected].b, 2);
	}
	
	// Reset color
	on_middle_click = function(_x, _y) {
		selected = clamp(floor(_y / w), 0, array_length(colors) - 1);
		
		color_picker_set(picker, oldColors[selected].rgb);
	}
	
	on_right_click = function(_x, _y) {
		selected = clamp(floor(_y / w), 0, array_length(colors) - 1);
		if keyboard_check(vk_control) {
			color_picker_set(picker, hex_to_color(clipboard_get_text()));
		} else {
			color_picker_set(picker, hex_to_color(get_string("","")));
		}
	}
	
	do_mwheel = function(_mw, _x, _y) {
		if ((_x >= x - 9 && _x <= x + w + 8)) {
		   if (_mw > 0 && y + (w * array_length(colors)) > room_height / 2) y -= 8;
		   else if (_mw < 0 && y < room_height / 2) y += 8;
		}
	}
	
	step = function() {
		surfSize = global.compression;
		
		var col = colors[selected],
			old = oldColors[selected],
			prev = colors[selected].rgb;
			
		col.rgb = color_picker_get(picker);
		col.degenerate();
		
		if (col.rgb != prev) {
			target_surface();
			var _x = floor(old.r * (surfSize / 256));
			var _y = floor(old.g * (surfSize / 256));
			draw_rectangle_color(_x, _y, _x, _y, col.rgb, col.rgb, col.rgb, col.rgb, false);
			surface_reset_target();
			hex.text = dec_to_hex(colors[selected].r, 2) + dec_to_hex(colors[selected].g, 2) + dec_to_hex(colors[selected].b, 2);
		}
		
		if (!surface_exists(renderSurface) || surface_get_width(renderSurface) != surfSize) {
			rerender_surface();
		}
	}
	
	update_color_hex = function() {
		var col = colors[selected],
			old = oldColors[selected];
		
		col.r = hex_to_dec(string_copy(hex.text, 1, 2));
		col.g = hex_to_dec(string_copy(hex.text, 3, 2));
		col.b = hex_to_dec(string_copy(hex.text, 5, 2));
		col.regenerate();
		
		color_picker_set(picker, colors[selected].rgb);
		
		target_surface();
		var _x = floor(old.r * (surfSize / 256));
		var _y = floor(old.g * (surfSize / 256));
		draw_rectangle_color(_x, _y, _x, _y, col.rgb, col.rgb, col.rgb, col.rgb, false);
		surface_reset_target();
	}
	
	on_draw = function() {
		var i = 0;
		repeat (array_length(colors)) {
			var col = oldColors[i];
			draw_rectangle_color(x - w - 1, y + (i * w), x - 2, y + w - 1 + (i * w), col.rgb, col.rgb, col.rgb, col.rgb, false);
			
			var col = colors[i];
			draw_rectangle_color(x, y + (i * w), x + w - 1, y + w - 1 + (i * w), col.rgb, col.rgb, col.rgb, col.rgb, false);
			if (col.collision != -1) {
				draw_line_color(x + w, y + (i * w) + w / 2, x + w + 6, y + (i * w) + w / 2, colors[col.collision].rgb, c_orange);
				draw_line_color(x + w + 6, y + (i * w) + w / 2, x + w + 6, y + (col.collision * w) + w / 2, c_orange, c_orange);
				draw_line_color(x + w, y + (col.collision * w) + w / 2, x + w + 6, y + (col.collision * w) + w / 2, colors[col.collision].rgb, c_orange);
			}
			++i;
		}
		
		draw_rectangle_color(x, y + (selected * w), x + w - 1, y + w + (selected * w) - 1, c_white, c_white, c_aqua, c_white, true);
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		
		var rampDist = floor(w * 2.5);
		draw_text(x + rampDist, ystart - 40 + yOffset, "Original RGB: " + string(oldColors[selected].r) + "," + string(oldColors[selected].g) + "," + string(oldColors[selected].b));
		draw_text(x + rampDist, ystart - 31 + yOffset, "Original Hex: " + dec_to_hex(oldColors[selected].r, 2) + dec_to_hex(oldColors[selected].g, 2) + dec_to_hex(oldColors[selected].b, 2));
		
		draw_text(x + rampDist, ystart - 16 + yOffset, "RGB: " + string(colors[selected].r) + "," + string(colors[selected].g) + "," + string(colors[selected].b));
		draw_text(x + rampDist, ystart - 7 + yOffset, "Hex:");
	}
}

function TextBox(_x, _y, _text, _limit) : ScreenElement(_x, _y, 128, 8) constructor {
	text = _text;
	limit = _limit;
	
	on_click = function(_x, _y) {
		keyboard_string = text;
	}
	
	on_update_click = function(_x, _y) {
		if (string_length(keyboard_string) <= limit) {
			text = keyboard_string;
		}
		else {
			keyboard_string = text;
		}
		if (keyboard_check_pressed(vk_enter)) {
			text = string_upper(text);
			global.selectedElement = noone;
			text = string_upper(text);
			parent.update_color_hex();
		}
	}
	
	on_release_click = function(_x, _y) {
		// do nothing!!! Overriding the release of control
	}
	
	on_draw = function() {
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		
		if (global.selectedElement == self) draw_set_color(c_yellow);
		else draw_set_color(c_white);
		
		draw_text(x, y, text);
		draw_set_color(c_white);
	}
}

// Sprite + array of its colors.
function AdvancedSprite(_index) constructor {
	image = _index;
	colors = array_create(0);
	// This is cursed so bear with me
	
	#region COLOR CREATION
	
	// Get width/height
	var w = sprite_get_width(image),
		h = sprite_get_height(image);
		
	// Create buffer - we will stuff our sprite in here after rendering it to a surface
	var colorBuffer = buffer_create(w * h * 4, buffer_fixed, 1);
	
	#region SURFACE GARBAGE
	// Create surface, target, and clear
	var surf = surface_create(w, h);
	surface_set_target(surf);
	draw_clear_alpha(c_black, 0);
		
	// Draw sprite to surface and reset target
	draw_sprite(image, 0, 0, 0);
	surface_reset_target();
		
	// Stuff surface into buffer and free surface
	buffer_get_surface(colorBuffer, surf, 0);
	surface_free(surf);
	
	#endregion
		
	// Seek to start of buffer
	buffer_seek(colorBuffer, buffer_seek_start, 0);
	
	// Repeat buffer length in bytes divided by 4 because we'll be reading 4 at a time - RGBA
	repeat (buffer_get_size(colorBuffer) / 4) {
		// Read order is vital!
		var r = buffer_read(colorBuffer, buffer_u8),
			g = buffer_read(colorBuffer, buffer_u8),
			b = buffer_read(colorBuffer, buffer_u8);
		
		// If alpha is 0, skip the rest of the iteration
		if (buffer_read(colorBuffer, buffer_u8) == 0) continue;
			
		// Skip rest of iteration if color is found in existing palette
		var skip = false,
			j = 0;
		repeat (array_length(colors)) {
			if (colors[j].r == r && colors[j].g == g && colors[j].b == b) {
				skip = true;
				break;
			}
			++j;
		}
		if (skip) continue;
		
		// Push value to array
		array_push(colors, new Color(r, g, b));
	}
		
	// Delete buffer
	buffer_delete(colorBuffer);
	
	#endregion
}

// Data container for color values.
function Color(_r, _g, _b) constructor {
	r = _r;
	g = _g;
	b = _b;
	rgb = make_color_rgb(r, g, b);
	collision = -1;
	
	// Call after modifying rgb values to update draw color
	static regenerate = function() {
		rgb = make_color_rgb(r, g, b);
	}
	
	static degenerate = function() {
		r = color_get_red(rgb);
		g = color_get_green(rgb);
		b = color_get_blue(rgb);
	}
	
	static set = function(_r = r, _g = g, _b = b) {
		r = _r;
		g = _g;
		b = _b;
	}
}

function ScreenElement(_x, _y, _w, _h) constructor {
	x = _x;
	y = _y;
	w = _w;
	h = _h;
	subElements = array_create(0);
	parent = other;
	
	static do_click = function(_x, _y) {
		if (point_in_rectangle(_x, _y, x, y, x + w, y + h)) {
			on_click(_x - x, _y - y);
			global.selectedElement = self;
		}
		else {
			var i = 0;
			repeat (array_length(subElements)) {
				subElements[i].do_click(_x, _y);
				++i;
			}
		}
	}
	
	do_mwheel = function(_mw, _x, _y) {
		
	}
	
	static do_middle_click = function(_x, _y) {
		if (point_in_rectangle(_x, _y, x, y, x + w, y + h)) {
			on_middle_click(_x - x, _y - y);
		}
	}
	
	on_middle_click = function(_x, _y) { }
	
	static do_right_click = function(_x, _y) {
		if (point_in_rectangle(_x, _y, x, y, x + w, y + h)) {
			on_right_click(_x - x, _y - y);
		}
	}
	
	on_right_click = function(_x, _y) { }
	
	static update_click = function(_x, _y) {
		if (global.selectedElement == self) {
			on_update_click(_x - x, _y - y);
		}
		else {
			var i = 0;
			repeat (array_length(subElements)) {
				subElements[i].update_click(_x, _y);
				++i;
			}
		}
	}
	
	on_update_click = function(_x, _y) {
		
	}
	
	static release_click = function(_x, _y) {
		if (global.selectedElement == self) {
			on_release_click(_x - x, _y - y);
		}
		else {
			var i = 0;
			repeat (array_length(subElements)) {
				subElements[i].release_click(_x, _y);
				++i;
			}
		}
	}
	
	on_release_click = function(_x, _y) {
		if (global.selectedElement == self) global.selectedElement = noone;
	}
	
	on_click = function(_x, _y) {
		
	}
	
	static do_draw = function() {
		on_draw();
		
		var i = 0;
		repeat (array_length(subElements)) {
			subElements[i].on_draw();
			++i;
		}
	}
	
	on_draw = function() {
		
	}
	
	step = function() {
		
	}
}

function ColorRamp(_x, _y, _c) : ScreenElement(_x, _y, 255, 8) constructor {
	col = _c;
	val = 0;
	
	on_click = function(_x, _y) {
		val = _x;
		parent.update_color_rgb();
	}
	
	on_update_click = function(_x, _y) {
		val = clamp(_x, 0, 255);
		parent.update_color_rgb();
	}
	
	on_draw = function(_x, _y) {
		draw_rectangle_color(x, y, x + w, y + 7, c_grey, c_grey, c_grey, c_grey, true);
		draw_rectangle_color(x, y, x + w, y + 7, c_black, col, col, c_black, false);
		draw_line_color(x + val, y - 1, x + val, y + h - 1, c_white, c_white);
		
		draw_set_valign(fa_top);
		draw_set_halign(fa_left);
		draw_text(x + w + 5, y, string(val));
	}
}