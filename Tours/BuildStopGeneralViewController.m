

#import "BuildStopGeneralViewController.h"


@interface BuildStopGeneralViewController () <UITextFieldDelegate, UITextViewDelegate>


@property (weak, nonatomic) IBOutlet UITextField *buildStopGeneralTitle;
@property (weak, nonatomic) IBOutlet UITextView *buildStopGeneralTextField;


@end

@implementation BuildStopGeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.buildStopGeneralTitle.text = self.stop.title;
    self.buildStopGeneralTextField.text = self.stop.summary;
    self.buildStopGeneralTextField.delegate = self;
    self.buildStopGeneralTitle.delegate = self;

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated {

    self.stop.title = self.buildStopGeneralTitle.text;
    self.stop.summary = self.buildStopGeneralTextField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [[self view] endEditing:YES];
    return true;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{

    if ([text isEqualToString:@"\n"]) {

        [textView resignFirstResponder];
        return NO;
    }

    return YES;
}

@end
