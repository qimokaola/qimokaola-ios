
//
//  ZWFeedCell.m
//  Qimokaola
//
//  Created by Administrator on 16/8/25.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWFeedCell.h"
#import "UIColor+Extension.h"

#import "UMComResouceDefines.h"

#import "SDAutoLayout.h"
#import "SDWeiXinPhotoContainerView.h"
#import "LinqToObjectiveC.h"
#import "Masonry.h"
#import <YYKit/YYKit.h>

@interface ZWFeedCell ()

// 用户头像
@property (nonatomic, strong) UIImageView *avatarView;
// 用户名
@property (nonatomic, strong) UILabel *nameLabel;
// 用户性别图片
@property (nonatomic, strong) UIImageView *genderView;
// 时间标签
@property (nonatomic, strong) UILabel *timeLabel;
// 学校标签
@property (nonatomic, strong) UILabel *schoolLabel;
// 内容
@property (nonatomic, strong) UILabel *contentLabel;
// 图片容器
@property (nonatomic, strong) SDWeiXinPhotoContainerView *picContainerView;
// 喜欢按钮
@property (nonatomic, strong) UIButton *likeButton;
// 喜欢数量标签
@property (nonatomic, strong) UILabel *likeCountLabel;
// 评论按钮
@property (nonatomic, strong) UIButton *commentButton;
// 评论数量标签
@property (nonatomic, strong) UILabel *commentCountLabel;
// 操作按钮
@property (nonatomic, strong) UIButton *moreButton;
// 分享按钮
@property (nonatomic, strong) UIButton *collectButton;
// 分隔视图
@property (nonatomic, strong) UIView *separatorView;
// 水平分隔线1 三个按钮之上
@property (nonatomic, strong) UIView *horizontalLine1;
// 水平分隔线1 三个按钮之下
@property (nonatomic, strong) UIView *horizontalLine2;
// 竖直分隔线 点赞 与 分享按钮 之间
@property (nonatomic, strong) UIView *verticalLine1;
// 竖直分隔线 评论 与 分享按钮 之间
@property (nonatomic, strong) UIView *verticalLine2;
// Feed 作者
@property (nonatomic, strong) UMComUser *creator;

@property (nonatomic, assign) BOOL isLiked;
@property (nonatomic, assign) BOOL isCollected;

@end

@implementation ZWFeedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellEditingStyleNone;
        [self createSubViews];
        
    }
    
    return self;
}

- (void)createSubViews {
    
    // 内容字体大小
    CGFloat contentLabelFontSize = 16;
    
    // 中等文字字体大小
    CGFloat midFontSize = 15;
    
    // 较小文本的字体大小
    CGFloat smallFontSize = 12;
    
    CGFloat margin = 10.f;
    CGFloat smallMargin = 5.0f;
    CGFloat avatarHeightOrWidth = 43;
    CGFloat singleLineLabelMaxWidth = 200.f;
    CGFloat genderViewSize = 15;
    CGFloat buttonHeight = 40.f;
    CGFloat separatorViewHeight = 10.f;
    UIColor *separatorViewColor = universalGrayColor;
    CGFloat separatorLineSize = .5f;
    UIColor *sepatatorLineColor = defaultBackgroundColor;
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.layer.cornerRadius = avatarHeightOrWidth / 2;
    _avatarView.layer.masksToBounds = YES;
    _avatarView.userInteractionEnabled = YES;
    [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToUser)]];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:midFontSize];
    _nameLabel.numberOfLines = 1;
    _nameLabel.userInteractionEnabled = YES;
    [_nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToUser)]];
    
    _genderView = [[UIImageView alloc] init];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:smallFontSize];
    _timeLabel.numberOfLines = 1;
    _timeLabel.textColor = [UIColor lightGrayColor];
    
    _schoolLabel = [[UILabel alloc] init];
    _schoolLabel.font = [UIFont systemFontOfSize:smallFontSize];
    _schoolLabel.textColor = [UIColor lightGrayColor];
    _schoolLabel.numberOfLines = 1;
    _schoolLabel.alpha = 0.0;
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.font = [UIFont systemFontOfSize:contentLabelFontSize];
    _contentLabel.numberOfLines = 0;
    
    _picContainerView = [[SDWeiXinPhotoContainerView alloc] init];
    
    UIImage *backgroundImage = [[UIColor whiteColor] parseToImage];
    UIImage *highlightedBackgroundImage = [separatorViewColor parseToImage];
    
    UIFont *insideButtonFont = ZWFont(13);
    UIColor *insideButtonColor = [UIColor lightGrayColor];
    
    _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_likeButton setImage:[UIImage imageNamed:@"icon_feed_unlike"] forState:UIControlStateNormal];
    [_likeButton setImage:[UIImage imageNamed:@"icon_feed_liked"] forState:UIControlStateSelected];
    [_likeButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_likeButton setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
    [_likeButton addTarget:self action:@selector(likeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _likeCountLabel = [[UILabel alloc] init];
    _likeCountLabel.font = insideButtonFont;
    _likeCountLabel.textColor = insideButtonColor;
    [_likeButton addSubview:_likeCountLabel];
    
    _collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_collectButton setImage:[UIImage imageNamed:@"icon_feed_uncollect"] forState:UIControlStateNormal];
    [_collectButton setImage:[UIImage imageNamed:@"icon_feed_collected"] forState:UIControlStateSelected];
    [_collectButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_collectButton setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
    [_collectButton addTarget:self action:@selector(collectButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_commentButton setImage:[UIImage imageNamed:@"icon_comment"] forState:UIControlStateNormal];
    [_commentButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [_commentButton setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
    [_commentButton addTarget:self action:@selector(commentButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _commentCountLabel = [[UILabel alloc] init];
    _commentCountLabel.font = insideButtonFont;
    _commentCountLabel.textColor = insideButtonColor;
    [_commentButton addSubview:_commentCountLabel];
    
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreButton setImage:[UIImage imageNamed:@"icon_more_operation_menu"] forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(clickMoreButton) forControlEvents:UIControlEventTouchUpInside];
    _moreButton.imageView.contentMode = UIViewContentModeCenter;
    
    _separatorView = [[UIView alloc] init];
    _separatorView.backgroundColor = separatorViewColor;
    
    _horizontalLine1 = [[UIView alloc] init];
    _horizontalLine1.backgroundColor = sepatatorLineColor;
    
    _horizontalLine2 = [[UIView alloc] init];
    _horizontalLine2.backgroundColor = sepatatorLineColor;
    
    _verticalLine1 = [[UIView alloc] init];
    _verticalLine1.backgroundColor = sepatatorLineColor;
    
    _verticalLine2 = [[UIView alloc] init];
    _verticalLine2.backgroundColor = sepatatorLineColor;
    
    NSArray *views = @[_avatarView, _nameLabel, _genderView, _timeLabel, _schoolLabel, _contentLabel, _picContainerView, _moreButton, _likeButton, _commentButton, _collectButton, _separatorView, _horizontalLine1, _horizontalLine2, _verticalLine1, _verticalLine2];
    
    [self.contentView sd_addSubviews:views];
    
    UIView *contentView = self.contentView;
    
    _separatorView.sd_layout
    .leftEqualToView(contentView)
    .rightEqualToView(contentView)
    .topEqualToView(contentView)
    .heightIs(separatorViewHeight);
    
    _avatarView.sd_layout
    .leftSpaceToView(contentView, margin)
    .topSpaceToView(_separatorView, margin)
    .heightIs(avatarHeightOrWidth)
    .widthIs(avatarHeightOrWidth);
    
    _nameLabel.sd_layout
    .leftSpaceToView(_avatarView, margin)
    .topEqualToView(_avatarView)
    .heightIs(18);
    [_nameLabel setSingleLineAutoResizeWithMaxWidth:singleLineLabelMaxWidth];
    
    _genderView.sd_layout
    .leftSpaceToView(_nameLabel, smallMargin)
    .centerYEqualToView(_nameLabel)
    .heightIs(genderViewSize)
    .widthIs(genderViewSize);
    
    _timeLabel.sd_layout
    .leftEqualToView(_nameLabel)
    .bottomEqualToView(_avatarView)
    .heightIs(15);
    [_timeLabel setSingleLineAutoResizeWithMaxWidth:singleLineLabelMaxWidth];
    
    _schoolLabel.sd_layout
    .leftSpaceToView(_timeLabel, smallMargin)
    .topEqualToView(_timeLabel)
    .heightIs(15);
    [_schoolLabel setSingleLineAutoResizeWithMaxWidth:singleLineLabelMaxWidth];
    
    _contentLabel.sd_layout
    .leftSpaceToView(contentView, margin)
    .rightSpaceToView(contentView, margin)
    .topSpaceToView(_avatarView, margin)
    .autoHeightRatio(0);
    
    _picContainerView.sd_layout
    .leftEqualToView(_contentLabel);
    
    _moreButton.sd_layout
    .topSpaceToView(contentView, margin)
    .rightSpaceToView(contentView, margin)
    .widthIs(30)
    .heightIs(30);
    
    _horizontalLine1.sd_layout
    .leftEqualToView(contentView)
    .rightEqualToView(contentView)
    .heightIs(separatorLineSize);
    
    _likeButton.sd_layout
    .leftEqualToView(contentView)
    .topSpaceToView(_horizontalLine1, 0)
    .heightIs(buttonHeight)
    .widthRatioToView(contentView, 1.0 / 3.0);
    
    _likeCountLabel.sd_layout
    .leftSpaceToView(_likeButton.imageView, 5)
    .centerYEqualToView(_likeButton.imageView);
    
    _verticalLine1.sd_layout
    .leftSpaceToView(_likeButton, 0)
    .centerYEqualToView(_likeButton)
    .widthIs(separatorLineSize)
    .heightRatioToView(_likeButton, 0.6);

    _collectButton.sd_layout
    .leftSpaceToView(_likeButton, 0)
    .topEqualToView(_likeButton)
    .heightIs(buttonHeight)
    .widthRatioToView(_likeButton, 1.0);
    
    _verticalLine2.sd_layout
    .leftSpaceToView(_collectButton, 0)
    .centerYEqualToView(_likeButton)
    .widthIs(separatorLineSize)
    .heightRatioToView(_verticalLine1, 1.0);
    
    _commentButton.sd_layout
    .topEqualToView(_likeButton)
    .rightEqualToView(contentView)
    .heightIs(buttonHeight)
    .widthRatioToView(_likeButton, 1.0);
    
    _commentCountLabel.sd_layout
    .leftSpaceToView(_commentButton.imageView, 5)
    .centerYEqualToView(_commentButton.imageView);
    
    _horizontalLine2.sd_layout
    .leftEqualToView(contentView)
    .rightEqualToView(contentView)
    .topSpaceToView(_likeButton, 0.0)
    .heightIs(separatorLineSize);
    
    [self setupAutoHeightWithBottomView:_horizontalLine2 bottomMargin:0.f];
}

- (void)setFeed:(UMComFeed *)feed {
    _feed = feed;
    _creator = feed.creator;
    
    // 自定义字段 0为不匿名 1为匿名
    if (DecodeAnonyousCode(_feed.custom)) {
        [_avatarView setImageWithURL:[NSURL URLWithString:_creator.icon_url.small_url_string] placeholder:[UIImage imageNamed:@"avatar"]];
        _nameLabel.text = _creator.name;
    } else {
        _avatarView.image = _creator.gender.intValue == 0 ? [UIImage imageNamed:@"icon_anonymous_female"] : [UIImage imageNamed:@"icon_anonymous_male"];
        _nameLabel.text = kStudentCircleAnonyousName;
    }
    
    _schoolLabel.text = createSchoolName(_creator.custom);
    
    _genderView.image = _creator.gender.intValue == 0 ? [UIImage imageNamed:@"icon_gender_female"] : [UIImage imageNamed:@"icon_gender_male"];
    
    _timeLabel.text = createTimeString(_feed.create_time);
    
    _contentLabel.text = _feed.text;
    
    self.likeCount = _feed.likes_count;
    self.commentCount = _feed.comments_count;
    
    self.isLiked = _feed.liked.boolValue;
    self.isCollected = _feed.has_collected.boolValue;
    
    _picContainerView.thumbnailPicUrlStringArray = [_feed.image_urls linq_select:^id(UMComImageUrl *item) {
        return item.small_url_string;
    }];
    
    _picContainerView.highQuantityPicUrlStringArray = [_feed.image_urls linq_select:^id(UMComImageUrl *item) {
        return item.large_url_string;
    }];
    
    CGFloat picContainerViewTopMargin = 0.f;
    if (_feed.image_urls && feed.image_urls.count > 0) {
        picContainerViewTopMargin = 10;
        _horizontalLine1.sd_layout.topSpaceToView(_picContainerView, 10);
    } else {
        _horizontalLine1.sd_layout.topSpaceToView(_contentLabel, 10);
    }
    
    _picContainerView.sd_layout.topSpaceToView(_contentLabel, picContainerViewTopMargin);
}

- (void)setCommentCount:(NSNumber *)commentCount {
    _commentCount = commentCount;
    if (_commentCount.intValue != 0) {
        _commentCountLabel.text = _commentCount.stringValue;
        [_commentCountLabel sizeToFit];
    } else {
        _commentCountLabel.text = nil;
    }
}

- (void)setLikeCount:(NSNumber *)likeCount {
    _likeCount = likeCount;
    if (_likeCount.intValue != 0) {
        _likeCountLabel.text = _likeCount.stringValue;
        [_likeCountLabel sizeToFit];
    } else {
        _likeCountLabel.text = nil;
    }
}

- (void)setIsLiked:(BOOL)isLiked {
    _isLiked = isLiked;
    _likeButton.selected = _isLiked;
}

- (void)setIsCollected:(BOOL)isCollected {
    _isCollected = isCollected;
    _collectButton.selected = _isCollected;
}

#pragma mark - Action Methods

- (void)likeButtonClicked {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didClickLikeButtonInLikeState:atIndexPath:)]) {
        [self.delegate cell:self didClickLikeButtonInLikeState:self.isLiked atIndexPath:_indexPath];
    }
}

- (void)collectButtonClicked {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didClickCollectButtonInCollectState:atIndexPath:)]) {
        [self.delegate cell:self didClickCollectButtonInCollectState:self.isCollected atIndexPath:_indexPath];
    }
}

- (void)commentButtonClicked {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didClickCommentButtonAtIndexPath:)]) {
        [self.delegate cell:self didClickCommentButtonAtIndexPath:_indexPath];
    }
}

- (void)clickToUser {
    if (!DecodeAnonyousCode(_feed.custom)) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didClickUser:atIndexPath:)]) {
        [self.delegate cell:self didClickUser:_feed.creator atIndexPath:_indexPath];
    }
}

- (void)clickMoreButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didClickMoreButtonAtIndexPath:)]) {
        [self.delegate cell:self didClickMoreButtonAtIndexPath:_indexPath];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
