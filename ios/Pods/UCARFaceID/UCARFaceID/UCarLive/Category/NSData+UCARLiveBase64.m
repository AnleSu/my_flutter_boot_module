//
//  NSData+UCARLiveBase64.m
//  base64
//
//  Created by Matt Gallagher on 2009/06/03.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//
//  Comments converted to be ARC compatible

#import "NSData+UCARLiveBase64.h"

//
// Mapping from 6 bit pattern to ASCII character.
//
static unsigned char UcarLivebase64EncodeLookup[65] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

//
// Definition for "masked-out" areas of the UcarLivebase64DecodeLookup mapping
//
#define ucarlivexx 65

//
// Mapping from ASCII character to 6 bit pattern.
//
static unsigned char UcarLivebase64DecodeLookup[256] =
{
    ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, 
    ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, 
    ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, 62, ucarlivexx, ucarlivexx, ucarlivexx, 63, 
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, 
    ucarlivexx,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, 
    ucarlivexx, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, 
    ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, 
    ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, 
    ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, 
    ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, 
    ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, 
    ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, 
    ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, 
    ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, ucarlivexx, 
};

//
// Fundamental sizes of the binary and base64 encode/decode units in bytes
//
#define UcarLiveBINARY_UNIT_SIZE 3
#define UcarLiveBASE64_UNIT_SIZE 4

//
// UCARLiveNewBase64Decode
//
// Decodes the base64 ASCII string in the inputBuffer to a newly malloced
// output buffer.
//
//  inputBuffer - the source ASCII string for the decode
//  length - the length of the string or -1 (to specify strlen should be used)
//  outputLength - if not-NULL, on output will contain the decoded length
//
// returns the decoded buffer. Must be free'd by caller. Length is given by
//  outputLength.
//
void *UCARLiveNewBase64Decode(
    const char *inputBuffer,
    size_t length,
    size_t *outputLength)
{
    if (length == -1)
    {
        length = strlen(inputBuffer);
    }
    
    size_t outputBufferSize =
        ((length+UcarLiveBASE64_UNIT_SIZE-1) / UcarLiveBASE64_UNIT_SIZE) * UcarLiveBINARY_UNIT_SIZE;
    unsigned char *outputBuffer = (unsigned char *)malloc(outputBufferSize);
    
    size_t i = 0;
    size_t j = 0;
    while (i < length)
    {
        //
        // Accumulate 4 valid characters (ignore everything else)
        //
        unsigned char accumulated[UcarLiveBASE64_UNIT_SIZE];
        size_t accumulateIndex = 0;
        while (i < length)
        {
            unsigned char decode = UcarLivebase64DecodeLookup[inputBuffer[i++]];
            if (decode != ucarlivexx)
            {
                accumulated[accumulateIndex] = decode;
                accumulateIndex++;
                
                if (accumulateIndex == UcarLiveBASE64_UNIT_SIZE)
                {
                    break;
                }
            }
        }
        
        //
        // Store the 6 bits from each of the 4 characters as 3 bytes
        //
        // (Uses improved bounds checking suggested by Alexandre Colucci)
        //
        if(accumulateIndex >= 2)  
            outputBuffer[j] = (accumulated[0] << 2) | (accumulated[1] >> 4);  
        if(accumulateIndex >= 3)  
            outputBuffer[j + 1] = (accumulated[1] << 4) | (accumulated[2] >> 2);  
        if(accumulateIndex >= 4)  
            outputBuffer[j + 2] = (accumulated[2] << 6) | accumulated[3];
        j += accumulateIndex - 1;
    }
    
    if (outputLength)
    {
        *outputLength = j;
    }
    return outputBuffer;
}

//
// UCARLiveNewBase64Encode
//
// Encodes the arbitrary data in the inputBuffer as base64 into a newly malloced
// output buffer.
//
//  inputBuffer - the source data for the encode
//  length - the length of the input in bytes
//  separateLines - if zero, no CR/LF characters will be added. Otherwise
//      a CR/LF pair will be added every 64 encoded chars.
//  outputLength - if not-NULL, on output will contain the encoded length
//      (not including terminating 0 char)
//
// returns the encoded buffer. Must be free'd by caller. Length is given by
//  outputLength.
//
char *UCARLiveNewBase64Encode(
    const void *buffer,
    size_t length,
    bool separateLines,
    size_t *outputLength)
{
    const unsigned char *inputBuffer = (const unsigned char *)buffer;
    
    #define MAX_NUM_PADDING_CHARS 2
    #define OUTPUT_LINE_LENGTH 64
    #define INPUT_LINE_LENGTH ((OUTPUT_LINE_LENGTH / UcarLiveBASE64_UNIT_SIZE) * UcarLiveBINARY_UNIT_SIZE)
    #define CR_LF_SIZE 2
    
    //
    // Byte accurate calculation of final buffer size
    //
    size_t outputBufferSize =
            ((length / UcarLiveBINARY_UNIT_SIZE)
                + ((length % UcarLiveBINARY_UNIT_SIZE) ? 1 : 0))
                    * UcarLiveBASE64_UNIT_SIZE;
    if (separateLines)
    {
        outputBufferSize +=
            (outputBufferSize / OUTPUT_LINE_LENGTH) * CR_LF_SIZE;
    }
    
    //
    // Include space for a terminating zero
    //
    outputBufferSize += 1;

    //
    // Allocate the output buffer
    //
    char *outputBuffer = (char *)malloc(outputBufferSize);
    if (!outputBuffer)
    {
        return NULL;
    }

    size_t i = 0;
    size_t j = 0;
    const size_t lineLength = separateLines ? INPUT_LINE_LENGTH : length;
    size_t lineEnd = lineLength;
    
    while (true)
    {
        if (lineEnd > length)
        {
            lineEnd = length;
        }

        for (; i + UcarLiveBINARY_UNIT_SIZE - 1 < lineEnd; i += UcarLiveBINARY_UNIT_SIZE)
        {
            //
            // Inner loop: turn 48 bytes into 64 base64 characters
            //
            outputBuffer[j++] = UcarLivebase64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
            outputBuffer[j++] = UcarLivebase64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
                | ((inputBuffer[i + 1] & 0xF0) >> 4)];
            outputBuffer[j++] = UcarLivebase64EncodeLookup[((inputBuffer[i + 1] & 0x0F) << 2)
                | ((inputBuffer[i + 2] & 0xC0) >> 6)];
            outputBuffer[j++] = UcarLivebase64EncodeLookup[inputBuffer[i + 2] & 0x3F];
        }
        
        if (lineEnd == length)
        {
            break;
        }
        
        //
        // Add the newline
        //
        outputBuffer[j++] = '\r';
        outputBuffer[j++] = '\n';
        lineEnd += lineLength;
    }
    
    if (i + 1 < length)
    {
        //
        // Handle the single '=' case
        //
        outputBuffer[j++] = UcarLivebase64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = UcarLivebase64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
            | ((inputBuffer[i + 1] & 0xF0) >> 4)];
        outputBuffer[j++] = UcarLivebase64EncodeLookup[(inputBuffer[i + 1] & 0x0F) << 2];
        outputBuffer[j++] = '=';
    }
    else if (i < length)
    {
        //
        // Handle the double '=' case
        //
        outputBuffer[j++] = UcarLivebase64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
        outputBuffer[j++] = UcarLivebase64EncodeLookup[(inputBuffer[i] & 0x03) << 4];
        outputBuffer[j++] = '=';
        outputBuffer[j++] = '=';
    }
    outputBuffer[j] = 0;
    
    //
    // Set the output length and return the buffer
    //
    if (outputLength)
    {
        *outputLength = j;
    }
    return outputBuffer;
}

@implementation NSData (UCARLiveBase64)

//
// ucarlive_dataFromBase64String:
//
// Creates an NSData object containing the base64 decoded representation of
// the base64 string 'aString'
//
// Parameters:
//    aString - the base64 string to decode
//
// returns the NSData representation of the base64 string
//
+ (NSData *)ucarlive_dataFromBase64String:(NSString *)aString
{
    NSData *data = [aString dataUsingEncoding:NSASCIIStringEncoding];
    size_t outputLength;
    void *outputBuffer = UCARLiveNewBase64Decode([data bytes], [data length], &outputLength);
    NSData *result = [NSData dataWithBytes:outputBuffer length:outputLength];
    free(outputBuffer);
    return result;
}

//
// ucarlive_base64EncodedString
//
// Creates an NSString object that contains the base 64 encoding of the
// receiver's data. Lines are broken at 64 characters long.
//
// returns an NSString being the base 64 representation of the
//  receiver.
//
- (NSString *)ucarlive_base64EncodedString
{
    size_t outputLength;
    char *outputBuffer =
        UCARLiveNewBase64Encode([self bytes], [self length], true, &outputLength);
    
    NSString *result =
        [[NSString alloc] initWithBytes:outputBuffer length:outputLength encoding:NSASCIIStringEncoding];
    free(outputBuffer);
    return result;
}

@end
