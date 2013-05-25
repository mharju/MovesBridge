//
//  ViewController.m
//  MovesAnalysis
//
//  Created by Mikko Harju on 4.5.2013.
//  Copyright (c) 2013 Mikko Harju. All rights reserved.
//

#import "ViewController.h"
#import "MovesAPI.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [[MovesAPI sharedInstance] performAuthorization:^{
        NSLog(@"We are connected and ready to make queries!");
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
