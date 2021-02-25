#include "fbgfx.bi"
#include "FreeImage.bi"

Print "Mishka's image to Image converter"
Print

Declare Function loadImage(ByVal As String) As Any Ptr

Declare Function getArg( ByVal As String, ByVal As String = "" ) As String
Declare Function getNumArg( ByVal As String, ByVal As Double = 0.0 ) As Double
Declare Function getBooleanArg( ByVal As String, ByVal As Boolean = false ) As Boolean
Declare Function firstVal ( ByVal As String, ByVal As String = "", ByVal As String = "") As String
Declare Function lastArg() As String

Declare Function RGBtoCGA( ByVal As uInteger ) As uByte
Declare Function CGAtoANSI( ByVal As uByte ) As String
Declare Function RGBtoANSI( ByVal As uInteger ) As String

Declare Sub make_bw( ByVal As fb.Image Ptr )
Declare Sub make_ht( ByVal As fb.Image Ptr, ByVal As Integer )

Union pixel_fmt
	v As UInteger
	
	type
		b As uByte
		g As uByte
		r As uByte
		a As uByte
	end type
End Union

'------------------------------------------------------------------------------
Dim As String	pixel_4bit(16)		= { " ", "▗", "▖", "▄", "▝", "▐", "▞", "▟", "▘", "▚", "▌", "▙", "▀", "▜", "▛", "█" }
Dim As String	pixel_shaded(5)	= { " ", "░", "▒", "▓", "█" }
Dim As String	pixel_ascii(5)		= { " ", ".", "-", "+", "#" }

'------------------------------------------------------------------------------

Dim As String		fname 		= firstVal( getArg( "-i" ), getArg( "--input" ), lastArg() )

Dim As Integer		output_h 	= getNumArg("-h", 12)
Dim As Integer		output_w 	= getNumArg("-w", 22)

Dim As Integer		input_h
Dim As Integer		input_w

Dim As Any Ptr		input_img

Dim As Integer		std_out	= FreeFile

' Usage menu
if (Command(1) = "") or getBooleanArg("--help") Then
	Print "Usage:"
	Print Command(0) & " <mode> <args> <image>"
	Print
	Print "Arguments:"
	Print " -w            Output image width"
	Print " -h            Output image height"
	Print
	Print " --shaded	Use Unicode shading characters"
	Print " --2tone	Use 'high resoloution' halftone"
	Print " --block	Use the full block character and spaces"
	Print " --ascii	Use ascii characters"
	Print
	Print " --color	Output ANSII color codes (not available in all modes)"
	Print " --threshold    Specify the halftone threshold (0-255)"
	Print " --pallete      Specify the ASCII pallete to be used (only works in --ascii mode and only with ASCII characters)"
	Print
	
	End
Endif

' We cannot use print because we are activating fbgfx later
Open Cons For Output As #std_out

' Check filename
If fname = "" Then
	Print #std_out, "file??"
	Print #std_out, ""
	Close #std_out
	End
Endif

' Activate the graphics library
ScreenRes output_w,output_h,32,, fb.GFX_NULL

' Load the image
input_img = loadImage(fname)

If input_img = 0 Then
	Print #std_out, "Could not load " & fname
	Print #std_out, ""
	Close #std_out
	End
Endif

input_h = CPtr(fb.Image Ptr, input_img)->height - 1
input_w = CPtr(fb.Image Ptr, input_img)->width - 1

' Do what the user wants
If getBooleanArg("--2tone") Then
	' "High Res" halftone
	Dim As Integer	halftone_threshold	= getNumArg("--threshold", 127)
	
	' Prep the image
	If getBooleanArg("--color") Then
		Print #std_out, "Color is not supported in this mode"
	Endif
		
	make_bw( input_img )
	make_ht( input_img, halftone_threshold )
	
	' The bizz
	For y As Integer = 0 to output_h - 1
		For x As Integer = 0 to output_w - 1
			Dim As uByte		pixval
			Dim As pixel_fmt	sample
			
			Dim As Integer sample_x = (x/output_w) * input_w
			Dim As Integer sample_y = (y/output_h) * input_h

			Dim As Integer delta_x = ( input_w/output_w )/2
			Dim As Integer delta_y = ( input_h/output_h )/2
			
			' Pick the right character
			' Top left bit
			sample.v = point(sample_x, sample_y, input_img)
			If sample.r > 0 Then
				pixval = pixval or &b1000
			Endif
			
			' top right bit
			sample.v = point(sample_x + delta_x, sample_y, input_img)
			If sample.r > 0 Then
				pixval = pixval or &b0100
			Endif
			
			' bottom left bit
			sample.v = point(sample_x, sample_y + delta_y, input_img)
			If sample.r > 0 Then
				pixval = pixval or &b0010
			Endif
			
			' bottom right bit
			sample.v = point(sample_x + delta_x, sample_y + delta_y, input_img)
			If sample.r > 0 Then
				pixval = pixval or &b0001
			Endif
			
			Print #std_out, pixel_4bit(pixval);
		Next
		
		Print #std_out, ""
	Next
	
ElseIf getBooleanArg("--block") Then
	' Low res halftone
	Dim As Integer	halftone_threshold	= getNumArg("--threshold", 127)
	
	' Prep the image
	If getBooleanArg("--color") Then
		Print #std_out, "Color is not supported in this mode"
	Endif
	
	make_bw( input_img )
	make_ht( input_img, halftone_threshold )
	
	' The bizz
	For y As Integer = 0 to output_h - 1
		For x As Integer = 0 to output_w - 1
			Dim As uByte		pixval
			Dim As pixel_fmt	sample
			
			Dim As Integer sample_x = (x/output_w) * input_w
			Dim As Integer sample_y = (y/output_h) * input_h

			' Pick the right character
			sample.v = point(sample_x, sample_y, input_img)
			
			If sample.r > 0 Then
				pixval = &b1111
			Else
				pixval = &b0000
			Endif
			
			Print #std_out, pixel_4bit(pixval);
		Next
		
		Print #std_out, ""
	Next
	
ElseIf getBooleanArg("--shaded") Then
	' Shaded
	
	' Prep the image
	If getBooleanArg("--color") = false Then
		make_bw( input_img )
	Endif
	
	' The bizz
	For y As Integer = 0 to output_h - 1
		For x As Integer = 0 to output_w - 1
			Dim As uByte		pixval
			Dim As pixel_fmt	sample
			
			Dim As Integer sample_x = (x/output_w) * input_w
			Dim As Integer sample_y = (y/output_h) * input_h

			' Pick the right character
			sample.v = point(sample_x, sample_y, input_img)
			
			pixval = (sample.r/255) * (UBound(pixel_shaded) - 1)
			
			If getBooleanArg("--color") Then
				Print #std_out, RGBtoANSI( sample.v );
			Endif
			
			Print #std_out, pixel_shaded(pixval);
		Next
		
		Print #std_out, ""
	Next	
	
ElseIf getBooleanArg("--ascii") Then
	' Shaded ascii
	' Prep the image
	If getBooleanArg("--color") = false Then
		make_bw( input_img )
	Endif
	
	Dim As Boolean		custom_pixels
	Dim As String		c_palette = getArg("--palette")
	Dim As String		pixel_custom()
	
	If c_palette <> "" Then
		custom_pixels = true
		
		ReDim pixel_custom(len(c_palette))
		
		For i As Integer = 1 to len(c_palette)
			pixel_custom(i-1) = Mid(c_palette, i, 1)
		Next
	Endif
	
	' The bizz
	For y As Integer = 0 to output_h - 1
		For x As Integer = 0 to output_w - 1
			Dim As uByte		pixval
			Dim As pixel_fmt	sample
			
			Dim As Integer sample_x = (x/output_w) * input_w
			Dim As Integer sample_y = (y/output_h) * input_h

			' Pick the right character
			sample.v = point(sample_x, sample_y, input_img)
			
			If getBooleanArg("--color") Then
				Print #std_out, RGBtoANSI( sample.v );
			Endif
			
			If custom_pixels Then
				pixval = (sample.r/255) * (UBound(pixel_custom)-1)
				
				Print #std_out, pixel_custom(pixval);
			Else
				pixval = (sample.r/255) * (UBound(pixel_ascii)-1)
				
				Print #std_out, pixel_ascii(pixval);
			Endif
		Next
		
		Print #std_out, ""
	Next	
	
Else
	Print #std_out, "Please specify a mode."
Endif

Print #std_out, Chr(&h1B) & "[0m";

ImageDestroy(input_img)
Close #std_out

'------------------------------------------------------------------------------
Function getArg( ByVal argument As String, ByVal default_value As String = "" ) As String
	Dim As Integer count
	
	Do Until Command(count) = ""
		If Command(count) = argument Then
			Return Command(count + 1)
		Endif
		
		count += 1
	Loop
	
	Return default_value
End Function

Function getNumArg( ByVal argument As String, ByVal default_value As Double = 0.0 ) As Double
	Return val( getArg( argument, str(default_value) ) )
End Function

Function getBooleanArg( ByVal argument As String, ByVal default_value As Boolean = false ) As Boolean
	Dim As Integer count
	
	Do Until Command(count) = ""
		If Command(count) = argument Then
			Return true
		Endif
		
		count += 1
	Loop
	
	Return default_value
End Function

Function firstVal ( ByVal a As String, ByVal b As String = "", ByVal c As String = "") As String
	If a <> "" Then
		Return a
	ElseIf b <> "" Then
		Return b
	ElseIf c <> "" Then
		Return c
	Endif
	
	Return ""
End Function

Function lastArg() As String
	Dim As Integer count = 1
	
	Do Until Command(count) = ""
		If Command(count + 1) = "" and Left(command(count),1) <> "-" Then
			Return Command(count)
		Endif
		
		count += 1
	Loop
	
	Return ""
End Function

Function loadImage(ByVal filename As String) As Any Ptr
	If Len(filename) = 0 Then
		Return NULL
	End If

	Dim As FREE_IMAGE_FORMAT form = FreeImage_GetFileType(StrPtr(filename), 0)
	If form = FIF_UNKNOWN Then
		form = FreeImage_GetFIFFromFilename(StrPtr(filename))
	End If

	If form = FIF_UNKNOWN Then
		Return NULL
	End If

	Dim As UInteger flags = 0
	If form = FIF_JPEG Then
		flags = JPEG_ACCURATE
	End If

	Dim As FIBITMAP Ptr image = FreeImage_Load(form, StrPtr(filename), flags)
	If image = NULL Then
		'' FreeImage failed to read in the image
		Return NULL
	End If

	FreeImage_FlipVertical(image)

	Dim As FIBITMAP Ptr image32 = FreeImage_ConvertTo32Bits(image)

	Dim As UInteger w = FreeImage_GetWidth(image)
	Dim As UInteger h = FreeImage_GetHeight(image)

	Dim As fb.Image Ptr sprite = ImageCreate(w, h)

	Dim As Byte Ptr target = CPtr(Byte Ptr, sprite + 1)
	Dim As Integer target_pitch = sprite->pitch

	Dim As Any Ptr source = FreeImage_GetBits(image32)
	Dim As Integer source_pitch = FreeImage_GetPitch(image32)

	For y As Integer = 0 To (h - 1)
		memcpy(target + (y * target_pitch), _
			   source + (y * source_pitch), _
			   w * 4)
	Next

	FreeImage_Unload(image32)
	FreeImage_Unload(image)

	Return sprite
End Function

' image filters beyond here ---->

' Convert to 16 color CGA mode
Function RGBtoCGA( ByVal c As uInteger ) As uByte
	Dim As uByte		ret
	Dim As pixel_fmt	p
	Dim As uByte		thr = 64
	
	p.v = c
	
	' determine if the intensity bit should be set
	If ( p.r + p.g + p.b )/3 > 128 Then
		ret = ret or &b1000
		
		thr = 128
	Endif
	
	' Check if each channel is bright enough to be considdered "on"
	If p.r > thr Then
		ret = ret or &b0100
	Endif
	
	If p.g > thr Then
		ret = ret or &b0010
	Endif
	
	If p.b > thr Then
		ret = ret or &b0001
	Endif

	Return ret
End Function

' Encode a 16 CGA color as an ANSI escape code
Function CGAtoANSI( ByVal c As uByte ) As String
	Dim As Integer		cc = 30
	Dim As uByte		conv
	
	' Channel order is reversed in ANSI vs CGA
	If c and &b0100 Then
		conv = conv or &b0001
	Endif
	If c and &b0010 Then
		conv = conv or &b0010
	Endif
	If c and &b0001 Then
		conv = conv or &b0100
	Endif
	
	' Check the intensity bit
	If c and &b1000 Then
		cc = 90
	Endif
	
	If conv > 7 Then
		cc += conv - 8
	Else
		cc += conv
	Endif
	
	Return Chr(&h1B) & "[" & str(cc) & "m"
End Function

' combines the other color conversion functions
Function RGBtoANSI( ByVal c As uInteger ) As String
	Return CGAtoANSI(RGBtoCGA(c))
End Function

' Convert to black and white
Sub make_bw( ByVal image As fb.Image Ptr )
	Dim As pixel_fmt	cpxl	
	
	For y As Integer = 0 to image->height - 1
		For x As Integer = 0 to image->width - 1
			cpxl.v = point( x, y, image )
			
			PSet image, (x, y), rgb( (cpxl.r+cpxl.g+cpxl.b)/3, (cpxl.r+cpxl.g+cpxl.b)/3, (cpxl.r+cpxl.g+cpxl.b)/3 )
		Next
	Next
End Sub

' Convert to halftone
Sub make_ht( ByVal image As fb.Image Ptr, ByVal thr As Integer )
	Dim As pixel_fmt	cpxl	
	
	For y As Integer = 0 to image->height - 1
		For x As Integer = 0 to image->width - 1
			cpxl.v = point( x, y, image )
			
			If cpxl.r < thr Then
				PSet image, (x, y), rgb(0,0,0)
			Else
				PSet image, (x, y), rgb(255,255,255)
			Endif
		Next
	Next
End Sub

' Multi Pixel Mode constants
' 4bit codes to represent each group of 4 pixels
' MSB top left
' LSB bottom right
' 0000 " "
' 0001 "▗"
' 0010 "▖"
' 0011 "▄"
' 0100 "▝"
' 0101 "▐"
' 0110 "▞"
' 0111 "▟"
' 1000 "▘"
' 1001 "▚"
' 1010 "▌"
' 1011 "▙"
' 1100 "▀"
' 1101 "▜"
' 1110 "▛"
' 1111 "█"

