//
//  MasterViewController.m
//  APImageView
//
//  Created by Amit Priyadarshi on 09/02/16.
//  Copyright © 2016 AFAI. All rights reserved.
//

#import "MasterViewController.h"



@implementation ThumbCell
@end


@interface MasterViewController () {
    NSMutableArray* thumbList;
    NSMutableData* imageData;
}

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    thumbList = [NSMutableArray new];
    for (int i = 100; i < 800; i+=10) {
        NSDictionary* anObject = @{@"name":[NSString stringWithFormat:@"%d x %d image",i,i],
                               @"urlString":[NSString stringWithFormat:@"https://dummyimage.com/%dx%d/000/fff&text=Yo!",i,i]};
        [thumbList addObject:anObject];
    }
    
    imageData = [NSMutableData data];
    
    NSURLSessionConfiguration* sConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sConfig delegate:self delegateQueue:nil];
    NSURLRequest* requ = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://tomtoy.us/wp-content/uploads/2014/07/abstract-art-colorful.jpg"]];
//    NSURLSessionDownloadTask* dTask = [task downloadTaskWithRequest:requ];
//    [dTask resume];
    NSURLSessionTask *task = [session dataTaskWithRequest:requ];
    [task resume];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [imageData appendData:data];
    UIImage *downloadedImage = [UIImage imageWithData:imageData];
    dispatch_async(dispatch_get_main_queue(), ^{
        ThumbCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.thumbView.image = downloadedImage;
    });

    NSLog(@"*** %ld",data.length);
}



- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"1 - %@", location.absoluteString);
    UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
    //3
    dispatch_async(dispatch_get_main_queue(), ^{
        // do stuff with image
        
        
        ThumbCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.thumbView.image = downloadedImage;
    });
    
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
//    NSLog(@"2 - didWriteData=%lld, BytesWritten=%lld, ExpectedToWrite=%lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    //NSLog(@"%@",downloadTask.response.URL);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // do stuff with image
        
        
        ThumbCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.titleLabel.text = [NSString stringWithFormat:@"%0.2f ",(totalBytesWritten*100.0f)/(1.0f*totalBytesExpectedToWrite)];
    });

}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"3 - ResumeAtOffset=%lld, expectedTotalBytes=%lld", fileOffset, expectedTotalBytes);
}


- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)insertNewObject:(id)sender {
//    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
//    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
//        
//    // If appropriate, configure the new managed object.
//    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
//    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
//        
//    // Save the context.
//    NSError *error = nil;
//    if (![context save:&error]) {
//        // Replace this implementation with code to handle the error appropriately.
//        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@"showDetail"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
//        [controller setDetailItem:object];
//        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
//        controller.navigationItem.leftItemsSupplementBackButton = YES;
//    }
}

#pragma mark - Table View


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [thumbList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ThumbCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
//            
//        NSError *error = nil;
//        if (![context save:&error]) {
//            // Replace this implementation with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }
//}

- (void)configureCell:(ThumbCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *object = [thumbList objectAtIndex:indexPath.row];
    cell.titleLabel.text = [object objectForKey:@"name"];
    [cell.thumbView setImage:[UIImage imageNamed:@"AppIcon"]];
}

@end
