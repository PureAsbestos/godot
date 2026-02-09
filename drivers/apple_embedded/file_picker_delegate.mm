/**************************************************************************/
/*  file_picker_delegate.mm                                               */
/**************************************************************************/
/*                         This file is part of:                          */
/*                             GODOT ENGINE                               */
/*                        https://godotengine.org                         */
/**************************************************************************/
/* Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md). */
/* Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.                  */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

#include "file_picker_delegate.h"

@implementation FilePickerDelegate

- (instancetype)initWithCallback:(const Callable &)p_callback {
	self = [super init];
	if (self) {
		godot_callback = p_callback;
	}
	return self;
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
	if (godot_callback.is_valid()) {
		Vector<String> selected_paths;
		for (NSURL *url in urls) {
			selected_paths.push_back(String::utf8([url.path UTF8String]));
		}
		
		Variant status = true;
		Variant v_selected_paths = selected_paths;
		Variant selected_filter_index = 0;
		const Variant *args[3] = { &status, &v_selected_paths, &selected_filter_index };
		Variant ret;
		Callable::CallError ce;
		
		godot_callback.callp(args, 3, ret, ce);
		if (ce.error != Callable::CallError::CALL_OK) {
			ERR_PRINT(vformat("Failed to execute file dialog callback: %s.", Variant::get_callable_error_text(godot_callback, args, 3, ce)));
		}
	}
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
	if (godot_callback.is_valid()) {
		Variant status = false;
		Variant v_selected_paths = Vector<String>();
		Variant selected_filter_index = 0;
		const Variant *args[3] = { &status, &v_selected_paths, &selected_filter_index };
		Variant ret;
		Callable::CallError ce;
		
		godot_callback.callp(args, 3, ret, ce);
		if (ce.error != Callable::CallError::CALL_OK) {
			ERR_PRINT(vformat("Failed to execute file dialog callback: %s.", Variant::get_callable_error_text(godot_callback, args, 3, ce)));
		}
	}
}

@end
