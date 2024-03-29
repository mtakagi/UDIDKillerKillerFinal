#import "GetUniqueIdentifier.h"
#import "objc-runtime-new.h"

NSString *getUniqueIdentifier()
{
    class_t *cls = (__bridge class_t *)[UIDevice class]; // Class オブジェクトを class_t * 型にキャスト
    // static BOOL isRealized(class_t *cls) から
    const class_ro_t *ro = (cls->data()->flags & RW_REALIZED) ? cls->data()->ro : (const class_ro_t *)cls->data();    
    const method_list_t *m_list = ro->baseMethods; // クラスの持つメソッドのリスト
    method_list_t::method_iterator begin = m_list->begin();
    method_list_t::method_iterator end   = m_list->end();
    NSString *uniqueIdentifier;
    
#ifdef DEBUG
    if (cls->data()->flags & RW_REALIZED)
        NSLog(@"Realized.");
    else
        NSLog(@"Not realized.");
#endif
    
    for (; begin != end; ++begin) {
        NSString *selName = NSStringFromSelector(begin->name);
        
        if ([selName isEqualToString:@"uniqueIdentifier"]) {
            NSLog(@"uniqueIdentifier!!!!!!!!!!!!, addr=%p", begin->imp);
            uniqueIdentifier = begin->imp([UIDevice currentDevice], begin->name);
        }
    }
    
    return uniqueIdentifier;
}