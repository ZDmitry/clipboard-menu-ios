#import "ViewController.h"
#import "MenuManager.h"


#define MSEC  1000

#define DEF_TIMEOUT  (5 * MSEC)
#define MIN_TIMEOUT  100


@interface ViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSArray* _data;
}

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _data = [[[MenuManager inst] currentSection] allKeys];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"menu";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [_data objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    id obj = [[MenuManager inst] selectSection:[_data objectAtIndex:indexPath.row]];
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        [_table beginUpdates];
        [_table reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
        _data = [(NSDictionary*)obj allKeys];
        [_table endUpdates];
    } else {
        UIPasteboard* clipboard = [UIPasteboard generalPasteboard];
        clipboard.string = obj;
        
        [self showToast:@"Text copied to clipboard" withTimeout:1.5 * MSEC];
        
        BOOL secureEnabled = [[MenuManager inst] configBool:@"secure"  default:true];
        long secureTimeout = [[MenuManager inst] configLong:@"timeout" default:DEF_TIMEOUT];
        
        if (secureEnabled && secureTimeout > MIN_TIMEOUT) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secureTimeout * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                clipboard.string = @"";
            });
        }
    }
}

- (void) showToast:(NSString*)message withTimeout:(long)msec
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, msec * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

- (IBAction) upSection {
    NSDictionary* dict = [[MenuManager inst] upSection];
    if (dict) {
        [_table beginUpdates];
        [_table reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
        _data = [dict allKeys];
        [_table endUpdates];
    }
}

@end
