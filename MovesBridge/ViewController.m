//
//  ViewController.m
//  MovesAnalysis
//
//  Created by Mikko Harju on 4.5.2013.
//  Copyright (c) 2013 Mikko Harju. All rights reserved.
//

#import "ViewController.h"
#import "MovesAPI.h"

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <pthread.h>

#import "AFNetworking.h"
#import "mongoose.h"

static int content_length;

static int request_handler(struct mg_connection *connection) {
    @autoreleasepool {
        const struct mg_request_info *info = mg_get_request_info(connection);
    
        __block const char *response = NULL;
        __block pthread_cond_t request_cond = PTHREAD_COND_INITIALIZER;
        pthread_mutex_t request_mutex = PTHREAD_MUTEX_INITIALIZER;
        
        NSString *uri = [NSString stringWithUTF8String:info->uri];
        
        [[MovesAPI sharedInstance] getPath:uri parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            response = [operation.responseString cStringUsingEncoding:operation.responseStringEncoding];
            content_length = [operation.responseString  lengthOfBytesUsingEncoding:operation.responseStringEncoding];
            
            pthread_cond_signal(&request_cond);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            response = [[error description] cStringUsingEncoding:NSUTF8StringEncoding];
            content_length = [[error description] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            
            pthread_cond_signal(&request_cond);
        }];
        
        pthread_mutex_lock(&request_mutex);
        pthread_cond_wait(&request_cond, &request_mutex);

        pthread_mutex_destroy(&request_mutex);
        pthread_cond_destroy(&request_cond);
        
        // Send HTTP reply to the client
        mg_printf(connection,
                  "HTTP/1.1 200 OK\r\n"
                  "Content-Type: application/json\r\n"
                  "Content-Length: %d\r\n"        // Always set Content-Length
                  "\r\n",
                  content_length);
        
        mg_write(connection, response, content_length);
        return 1;
    }
}

@interface ViewController () {
    struct mg_context *context;
}
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@end

@implementation ViewController

// From: http://stackoverflow.com/questions/7072989/iphone-ipad-how-to-get-my-ip-address-programmatically
- (NSString*) localIp
{
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[MovesAPI sharedInstance] performAuthorization:^{
        NSLog(@"We are connected and ready to make queries!");
        
        const char *options[] = {"listening_ports", "8080", NULL};
        struct mg_callbacks callbacks = {0};
        memset(&callbacks, 0, sizeof(callbacks));
        
        callbacks.begin_request = request_handler;
        context = mg_start(&callbacks, (__bridge void *)(self), options);
        
        NSLog(@"Listening on %@:8080", [self localIp]);
    } failure:^(NSError *reason) {
        NSLog(@"We failed to connect: %@", [reason description]);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
