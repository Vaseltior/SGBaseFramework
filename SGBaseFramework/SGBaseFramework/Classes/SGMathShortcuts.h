//
//  SGMathShortcuts.h
//  SGBaseFramework
//
//  Created by Samuel Grau on 7/18/11.
//  Copyright 2011 Samuel Grau. All rights reserved.
//

#ifndef SGBaseFramework_SGMathShortcuts_h
#define SGBaseFramework_SGMathShortcuts_h

/** High precision float comparison
 * \param[in] a The first float to compare
 * \param[in] b The second float to compare
 * \return true if equal within precision, false if not equal within defined precision.
 */
static inline int a_compare_float(const float a, const float b) {
    const float precision = 0.00001;
    if((a - precision) < b && (a + precision) > b)
        return true;
    else
        return false;
}

/** High precision double comparison
 * \param[in] a The first double to compare
 * \param[in] b The second double to compare
 * \return true on equal within precison, false if not equal within defined precision.
 */
static inline int a_compare_double(const double a, const double b) {
    const double precision = 0.00001;
    if((a - precision) < b && (a + precision) > b)
        return true;
    else
        return false;
}


#endif
