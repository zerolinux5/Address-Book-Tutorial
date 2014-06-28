//
//  ViewController.m
//  PetBook
//
//  Created by Evan Dekhayser on 1/21/14.
//  Copyright (c) 2014 Evan Dekhayser. All rights reserved.
//

#import "ViewController.h"
@import AddressBook;

@interface ViewController ()

@end

@implementation ViewController


- (IBAction)petTapped:(UIButton *)sender {
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        //1
        UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [cantAddContactAlert show];
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        //2
        [self addPetToContacts:sender];
    } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        //3
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted){
                    //4
                    UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                    [cantAddContactAlert show];
                    return;
                }
                    //5
                    [self addPetToContacts:sender];
                });
            });
    }
}

- (void)addPetToContacts: (UIButton *) petButton{
    NSString *petFirstName;
    NSString *petLastName;
    NSString *petPhoneNumber;
    NSData *petImageData;
    if (petButton.tag == 1){
        petFirstName = @"Cheesy";
        petLastName = @"Cat";
        petPhoneNumber = @"2015552398";
        petImageData = UIImageJPEGRepresentation([UIImage imageNamed:@"contact_Cheesy.jpg"], 0.7f);
    } else if (petButton.tag == 2){
        petFirstName = @"Freckles";
        petLastName = @"Dog";
        petPhoneNumber = @"3331560987";
        petImageData = UIImageJPEGRepresentation([UIImage imageNamed:@"contact_Freckles.jpg"], 0.7f);
    } else if (petButton.tag == 3){
        petFirstName = @"Maxi";
        petLastName = @"Dog";
        petPhoneNumber = @"5438880123";
        petImageData = UIImageJPEGRepresentation([UIImage imageNamed:@"contact_Maxi.jpg"], 0.7f);
    } else if (petButton.tag == 4){
        petFirstName = @"Shippo";
        petLastName = @"Dog";
        petPhoneNumber = @"7124779070";
        petImageData = UIImageJPEGRepresentation([UIImage imageNamed:@"contact_Shippo.jpg"], 0.7f);
    }
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
    ABRecordRef pet = ABPersonCreate();
    ABRecordSetValue(pet, kABPersonFirstNameProperty, (__bridge CFStringRef)petFirstName, nil);
    ABRecordSetValue(pet, kABPersonLastNameProperty, (__bridge CFStringRef)petLastName, nil);
    ABMutableMultiValueRef phoneNumbers = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    ABMultiValueAddValueAndLabel(phoneNumbers, (__bridge CFStringRef)petPhoneNumber, kABPersonPhoneMainLabel, NULL);
    ABRecordSetValue(pet, kABPersonPhoneProperty, phoneNumbers, nil);
    ABPersonSetImageData(pet, (__bridge CFDataRef)petImageData, nil);
    ABAddressBookAddRecord(addressBookRef, pet, nil);
    NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    for (id record in allContacts){
        ABRecordRef thisContact = (__bridge ABRecordRef)record;
        if (CFStringCompare(ABRecordCopyCompositeName(thisContact),
                            ABRecordCopyCompositeName(pet), 0) == kCFCompareEqualTo){
            //The contact already exists!
            UIAlertView *contactExistsAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"There can only be one %@", petFirstName] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [contactExistsAlert show];
            return;
        }
    }
    
    ABAddressBookSave(addressBookRef, nil);
    UIAlertView *contactAddedAlert = [[UIAlertView alloc]initWithTitle:@"Contact Added" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [contactAddedAlert show];
    
}

@end
