//
//  IndexedPhotoCollectionView.h
//  Tours
//
//  Created by Gretchen Walker on 6/16/15.
//  Copyright (c) 2015 Mark Porcella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

static NSString *indexedPhotoCollectionViewCellID = @"CollectionViewCell";

@interface IndexedPhotoCollectionView : UICollectionView

//@property (nonatomic, strong) UIImageView *imageView; // not sure this is necessary
@property (nonatomic, strong) NSIndexPath *indexPath;


@end
